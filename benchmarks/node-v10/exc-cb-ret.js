var b, f;

// 73ms
b = 10000000;
f = function ( a, c ) {
	return a + 0;
}
console.time( '10000000-iterations_return-error' );
while ( b-- ) {
	b = f( b, Math.random() );
}
console.timeEnd( '10000000-iterations_return-error' );

// 186ms
b = 10000000;
f = function ( a, c, cb ) {
	cb( null, a + 0 );
}
var cb = function ( err, res ) {
	b = res;
};
console.time( '1000000-iterations_pass-error-callback_optimized' );
while ( b-- ) {
	f( b, Math.random(), cb );
}
console.timeEnd( '1000000-iterations_pass-error-callback_optimized' );

// 292ms
b = 10000000;
f = function ( a, c ) {
	return a + 0;
}
console.time( '10000000-iterations_throw-error' );
while ( b-- ) {
	try {
		b = f( b, Math.random() );
	} catch ( e ) {
		console.log( e );
	}
}
console.timeEnd( '10000000-iterations_throw-error' );

// 407ms
b = 100000000;
f = function ( a, c, cb ) {
	cb( null, a + 0 );
}
console.time( '1000000-iterations_pass-error-callback' );
while ( b-- ) {
	f( b, Math.random(), function ( err, res ) {
		b = res;
	} );
}
console.timeEnd( '1000000-iterations_pass-error-callback' );
