#!/usr/bin/php -nc=/etc/php5/cli/php.daemon.ini
<?php

// PID файл манагера
define( 'PID_FILE', '/var/run/'. basename( __FILE__, '.php' ) .'.pid' );
// тики манагера в сек
define( 'MANAGER_CYCLE_DELAY', 3 );
// тики воркета в микросекундах
define( 'WORKER_CYCLE_DELAY', 500000 );
// максимальное количество воркеров
define( 'MAX_WORKERS', 20 );

define( 'LAUNCHER', 1 );
define( 'MANAGER', 2 );
define( 'WORKER', 3 );

define( 'STDOUT_FILENAME', '/var/wwws/api-v2.bossnote.ru/htdocs/test/'. basename( __FILE__, '.php' ) .'.stdout.log' );
define( 'STDERR_FILENAME', '/var/wwws/api-v2.bossnote.ru/htdocs/test/'. basename( __FILE__, '.php' ) .'.stderr.log' );

$worker_processes = [];
$process_type = LAUNCHER;

// Cброс маски режимов создания файлов в 0,чтоб маскировать некоторые биты прав доступа от запускающего процесса.
umask( 0 );

// синглонизация манагера
if ( is_readable( PID_FILE ) ) {

	$PID = (int) file_get_contents( PID_FILE );

	if ( $PID > 0 && posix_kill( $PID, 0 ) ) {
		
		echo "Daemon manager already running, PID=$PID\n";
		exit;
	}

	if ( !unlink( PID_FILE ) ) {
		
		echo "ERROR! Daemon manager not running, but cat't remove PID file\n";
		exit( -1 );
	}
}

// раз мы тут демона нет

// Создаем дочерний процесс
// весь код после pcntl_fork() будет выполняться двумя процессами: родительским и дочерним
$PID = pcntl_fork();

if ( $PID < 0 ) {
	
	// не смогли форкнуться, печалька
	echo "ERROR! Fork failed!\n";
	exit( -1 );
	
} elseif ( $PID ) {
	
	// тут продолжается процесс-лаунчер
	echo "Daemon successfully started\n";
	exit;
	
} else {
	
	// тут мы в процессе-манагера-деток
	
	$process_type = MANAGER;
	pcntl_setpriority( 10 );
	$PID = posix_getpid();
	
	umask( 0 );
	chdir( '/' );
	
	// устанавливаем лог файл
	ini_set( 'error_log', STDERR_FILENAME );
	
	// перенаправляем stderr в лог-файл
	fclose( STDERR );
	$STDERR = fopen( STDERR_FILENAME, 'ab' );

	if ( !file_put_contents( PID_FILE, $PID ) ) {
		
		error_log( 'PID file write failed!' );
		exit;
	}

	// перенаправляем stdin в /dev/null
	fclose( STDIN );
	$STDIN = fopen( '/dev/null', 'r' );
	
	// перенаправляем stdout в лог-файл
	fclose( STDOUT );
	$STDOUT = fopen( STDOUT_FILENAME, 'ab' );
	
	// Без этой директивы PHP не будет перехватывать сигналы
	declare( ticks=1 );
	// установка обработчика сигнала
	pcntl_signal( SIGTERM, "sig_handler" );
	pcntl_signal( SIGQUIT, "sig_handler" );
	pcntl_signal( SIGCHLD, "sig_handler" );
	
	info_log( 'PID file write ok!' );
	
	if ( posix_setsid() == -1 ) {
		
		error_log( 'setsid failed' );
		exit;
	}
	
	info_log( "Successfully started" );
	$stop_server = false;
	
	while ( !$stop_server ) {

		info_log( "Tick begin" );
		
		if ( !$stop_server && ( count( $worker_processes ) < MAX_WORKERS ) ) {
			
			// плодим дочерний процесс
			info_log( "Starting worker id=". ( count( $worker_processes ) + 1 ) );
			$PID = pcntl_fork();
			if ( $PID == -1 ) {
				
				info_log( "Starting worker id=". ( count( $worker_processes ) + 1 ) ." failed!" );
				
			} elseif ($PID) {
				
				//процесс создан
				$worker_processes[ $PID ] = true;
				info_log( "Starting worker id=". count( $worker_processes ) ." successfully!" );
				
			} else {

				// тут продолжает работать worker

				$process_type = WORKER;
				pcntl_setpriority( 5 );
				$PID = posix_getpid();
				info_log( "Successfully started" );
				
				$stop_child = 7;
				
				while ( $stop_child ) {
					
					info_log( "Tick begin, $stop_child" );
					
					// TODO Что-то важное что должен делать worker

					usleep( WORKER_CYCLE_DELAY );
					$stop_child--;
				}

				// worker дохнет
				info_log( "Finished" );
				exit;
			}
		} else {
			
			sleep( MANAGER_CYCLE_DELAY );
		}
	}
	
	info_log( "Finished" );
	
}




function sig_handler (
		$signo
) {
	
	global $process_type, $worker_processes, $PID;

	switch ( $process_type ) {

		case MANAGER:
				
			switch ( $signo ) {

				case SIGTERM:
				case SIGQUIT:
					
					info_log( ( $signo == SIGTERM ? 'SIGTERM' : 'SIGQUIT' ) ." received." );

					foreach ( array_keys( $worker_processes ) as $k => $PID ) {
							
						unset( $worker_processes[ $PID ] ) ;
						info_log( "Sending SIGTERM to worker id=$k, PID=$PID" );
						posix_kill( $PID, SIGTERM );
					}
					// TODO Что-то важное что должен сделать manager когда его закрывают					
					info_log( "Exiting" );
					if ( !unlink( PID_FILE ) )
						error_log( "ERROR! Daemon manager not running, but cat't remove PID file" );
					exit;
					break;
					
				case SIGCHLD:
					
					while ( ( $pid = pcntl_waitpid( -1, $status, WNOHANG ) ) > 0 ) {

						if ( $pid != -1 ) {
							
							info_log( "SIGCHLD received from worker PID=$pid" );
							unset( $worker_processes[ $pid ] );
							
						} else {
							
							$worker_processes = [];
						}
					}			
					break;
			}
			break;
				
		case WORKER:
			switch ( $signo ) {
				case SIGTERM:
					info_log( "SIGTERM received" );
					// TODO Что-то важное что должен сделать worker когда его закрывают
					info_log( "Exiting" );
					exit;
					break;
			}
			break;
	}
}


function info_log (
		$message
	) {

	global $PID, $process_type;
	echo date( '[d-M-Y H:i:s e]' ) ."[$PID][". ( $process_type == WORKER ? 'w' : 'M' ) . "] $message\n";
}