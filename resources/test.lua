print("lua start:")
for i=1,5 do
    print("lua hello ...")
end
print("lua fib(10) = " .. lua_my_call('lua_my_fib', 10))
print("lua end!")
-- fix 