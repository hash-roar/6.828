#include "kernel/types.h"
#include "user/user.h"

int main( int argc, char* argv[] ) {
  int pipe_to_child[ 2 ];
  int pipe_to_parent[ 2 ];
  if ( pipe( pipe_to_child ) < 0 ) {
    fprintf( 2, "init pipe error" );
    exit( 1 );
  };
  if ( pipe( pipe_to_parent ) < 0 ) {
    fprintf( 2, "init pipe error" );
    exit( 1 );
  };

  if ( fork() == 0 ) {
    close( pipe_to_child[ 1 ] );
    char buf[ 10 ]     = {};
    int  child_pid     = getpid();
    char pid_str[ 10 ] = {};
    tostr( child_pid, pid_str, 10 );

    read( pipe_to_child[ 0 ], buf, 10 );
    fprintf( 1, pid_str, ": received ping" );
    write( pipe_to_parent[ 1 ], "pong", 4 );
    close( pipe_to_parent[ 1 ] );
  }
  else {
    close( pipe_to_parent[ 1 ] );
    write( pipe_to_child[ 1 ], "ping", 4 );
    char buf[ 10 ]     = {};
    int  parent_pid    = getpid();
    char pid_str[ 10 ] = {};
    tostr( parent_pid, pid_str, 10 );
    read( pipe_to_parent[ 0 ], buf, 10 );
    fprintf( 1, pid_str, ": received pong" );
  }

  exit( 0 );
}
