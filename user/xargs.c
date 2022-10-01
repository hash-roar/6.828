#include "kernel/param.h"
#include "kernel/types.h"
#include "user/user.h"

int main( int argc, char* argv[] ) {
  if ( argc < 3 ) {
    fprintf( 2, "usage: find path pattern" );
    exit( 0 );
  }
  char* exec_argv[ MAXARG ] = {};
  // read from standard input
  char buf[ 128 ] = {};
  memset( buf, 0, 128 );
  char* p = buf;

  // read until eof
  while ( read( 0, p, 1 ) ) {
    if ( *p++ != '\n' ) {
      continue;
    }

    for ( int i = 2; i < argc; i++ ) {
      exec_argv[ i - 1 ] = argv[ i ];
    }
    exec_argv[ argc - 1 ] = buf;
    exec_argv[ argc ]     = 0;

    if ( fork() == 0 ) {
      exec( argv[ 1 ], exec_argv );
    }
    else {
      wait( ( int* )0 );
    }

    memset( buf, 0, 128 );
    p = buf;
  }

  //   struct result_info result = {};

  exit( 0 );
}
