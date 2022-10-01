#include "kernel/types.h"
#include "user/user.h"

void Pipe( int pipe_from_parent[ 2 ] ) {
  // close write of pipe from parent
  close( pipe_from_parent[ 1 ] );

  int buf[ 36 ] = {};

  // read data from parent
  int n = 0;
  read( pipe_from_parent[ 0 ], &n, sizeof( int ) );
  fprintf( 2, "prime %d", n );
  if ( n == 35 ) {
    exit( 0 );
  }
  int intbuf = 0;
  int total  = 0;
  while ( read( pipe_from_parent[ 0 ], &intbuf, sizeof( int ) ) ) {
    if ( intbuf / n == 0 ) {
      continue;
    }
    else {
      buf[ total++ ] = intbuf;
    }
  }
  close( pipe_from_parent[ 0 ] );

  // init pipe to child
  int pip_to_child[ 2 ] = {};
  if ( pipe( pip_to_child ) < 0 ) {
    fprintf( 2, "init pipe error" );
  }
  close( pip_to_child[ 0 ] );
  int pid = fork();
  if ( pid == 0 ) {
    Pipe( pip_to_child );
  }
  else {
    while ( --total ) {
      write( pip_to_child[ 1 ], &buf[ total ], sizeof( int ) );
    }
    close( pip_to_child[ 1 ] );
    wait( &pid );
  }
}

int main( int argc, char* argv[] ) {

  int pipe_to_child[ 2 ] = {};
  if ( pipe( pipe_to_child ) < 0 ) {
    fprintf( 2, "error happen at init pipe" );
  }
  close( pipe_to_child[ 0 ] );

  if ( fork() == 0 ) {
    Pipe( pipe_to_child );
  }
  else {

    for ( int i = 2; i <= 35; i++ ) {
      write( pipe_to_child[ 1 ], &i, sizeof( i ) );
    }
    close( pipe_to_child[ 1 ] );
    int child_pid = -1;
    wait( &child_pid );
  }

  exit( 0 );
}