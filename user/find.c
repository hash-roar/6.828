#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

// struct result_info {
//   char* result[ 100 ];  // TODO:
//   int   cur;
// };

void find_in_dir( char* path, char* target ) {
  char          buf[ 512 ], *p;
  int           fd;
  struct dirent de;
  struct stat   st;
  if ( ( fd = open( path, 0 ) ) < 0 ) {
    fprintf( 2, "ls: cannot open %s\n", path );
    return;
  }
  if ( fstat( fd, &st ) < 0 ) {
    fprintf( 2, "ls: cannot stat %s\n", path );
    close( fd );
    return;
  }
  // check param validation
  if ( st.type != T_DIR ) {
    fprintf( 2, "%s is not dir\n", path );
    close( fd );
    return;
  }
  if ( strlen( path ) + 1 + DIRSIZ + 1 > sizeof buf ) {
    printf( "ls: path too long\n" );
    return;
  }
  strcpy( buf, path );
  p    = buf + strlen( buf );
  *p++ = '/';
  while ( read( fd, &de, sizeof( de ) ) == sizeof( de ) ) {
    if ( de.inum == 0 )
      continue;
    memmove( p, de.name, DIRSIZ );
    p[ DIRSIZ ] = 0;
    if ( stat( buf, &st ) < 0 ) {
      printf( "ls: cannot stat %s\n", buf );
      continue;
    }

    switch ( st.type ) {
    case T_FILE: {
      // get file base name
      if ( strcmp( de.name, target ) == 0 ) {
        fprintf( 1, "%s", buf );
      }
      break;
    }
    case T_DIR: {
      if ( strcmp( de.name, "." ) == 0 || strcmp( de.name, ".." ) == 0 ) {
        break;
      }
      find_in_dir( buf, target );
      break;
    }
    }
  }

  close( fd );
}

int main( int argc, char* argv[] ) {
  if ( argc < 3 ) {
    fprintf( 2, "usage: find path pattern" );
    exit( 0 );
  }
  char* path   = argv[ 1 ];
  char* target = argv[ 2 ];
  find_in_dir( path, target );
  //   struct result_info result = {};

  exit( 0 );
}
