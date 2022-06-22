print("lua start:")
for i=1,10 do
    print("hello from lua ...")
end
print("fib(10)=" .. call('fib', 10))
print("lua end!")