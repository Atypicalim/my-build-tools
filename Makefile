
LDFLAGS = -s -lopengl32 -lgdi32  -O2 -mwindows

demo : 
	g++ test.c ./tigr.c -o test.exe $(LDFLAGS)
