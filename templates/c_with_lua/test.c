
#define LUA_IMPL
#define LUAA_LUAIMPLEMENTATION
#include "minilua.h"
#include "lautoc.c"

char LUA_SCRIPT[] = "%s"; // [M[ FILE_STRING | ./test.lua ]M]

int fib(int n) {
  if (n == 0) { return 0; }
  if (n == 1) { return 1; }
  return fib(n-1) + fib(n-2);
}

int call(lua_State* L) {
  return luaA_call_name(L, lua_tostring(L, 1));
}

int main() {
  lua_State *L = luaL_newstate();
  if(L == NULL) return -1;

  luaA_open(L);
  luaA_function(L, fib, int, int);
  lua_register(L, "call", call);

  luaL_openlibs(L);
  luaL_loadstring(L, LUA_SCRIPT);
  lua_call(L, 0, 0);
  
  luaA_close(L);
  lua_close(L);
  return 0;
}
