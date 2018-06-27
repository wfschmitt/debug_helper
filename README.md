# Debug Helper

This helper assists in [printf debugging](https://en.wikipedia.org/wiki/Debugging#Techniques), by printing (to ```stdout```) an analysis of a given object.

Classes closely supported:

- [Hash](#hash)
- [Struct](#struct)
- [String](#string)
- [Symbol](#symbol)

And not so much:

- [Object](#object)

### Hash

#### Simple Hash

This example shows a simple hash.

```show.rb```:
```ruby
require 'debug_helper'

hash = {:a => 0, :b => 1, :c => 2}
DebugHelper.show(hash, 'My simple hash')
```

The output shows details of the hash.

```show.yaml```:
```yaml
---
Hash (size=3 name=My simple hash):
  Pair 0:
    Key:
      Symbol (size=1): :a
    Value: 0 (Fixnum)
  Pair 1:
    Key:
      Symbol (size=1): :b
    Value: 1 (Fixnum)
  Pair 2:
    Key:
      Symbol (size=1): :c
    Value: 2 (Fixnum)
```

#### Mixed Hash

This example shows a hash of mixed values.

```show.rb```:
```ruby
require 'debug_helper'

hash = {
    :a => 0,
    :b => 'one',
    :c => :two,
}
DebugHelper.show(hash, 'My mixed hash')
```

The output shows details of the hash.

```show.yaml```:
```yaml
---
Hash (size=3 name=My mixed hash):
  Pair 0:
    Key:
      Symbol (size=1): :a
    Value: 0 (Fixnum)
  Pair 1:
    Key:
      Symbol (size=1): :b
    Value:
      String (size=3 encoding=UTF-8):
      - one
  Pair 2:
    Key:
      Symbol (size=1): :c
    Value:
      Symbol (size=3): :two
```

#### Nested Hashes

This example shows nested hashes.

```show.rb```:
```ruby
require 'debug_helper'

hash = {
    :a => {
        :b => 0,
        :c => 1,
    }
}
DebugHelper.show(hash, 'My nested hash')
```

The output shows details of the hashes.

```show.yaml```:
```yaml
---
Hash (size=1 name=My nested hash):
  Pair 0:
    Key:
      Symbol (size=1): :a
    Value:
      Hash (size=2):
        Pair 0:
          Key:
            Symbol (size=1): :b
          Value: 0 (Fixnum)
        Pair 1:
          Key:
            Symbol (size=1): :c
          Value: 1 (Fixnum)
```

#### Circular Hashes

This example shows hashes that make a circular reference.

```show.rb```:
```ruby
require 'debug_helper'

hash_0 = {}
hash_1 = {}
hash_0.store(:foo, hash_1)
hash_1.store(:bar, hash_0)
DebugHelper.show(hash_0, 'My circular hashes')
```

The output shows details of the hashes.

The circular reference is not followed.

```show.yaml```:
```yaml
---
Hash (size=1 name=My circular hashes):
  Pair 0:
    Key:
      Symbol (size=3): :foo
    Value:
      Hash (size=1):
        Pair 0:
          Key:
            Symbol (size=3): :bar
          Value: "{:foo=>{:bar=>{...}}} (Hash)"
```
### Struct

#### Simple Struct

This example shows a simple struct.

```show.rb```:
```ruby
require 'debug_helper'

MyStruct = Struct.new(:a, :b, :c)
struct = MyStruct.new(0, 1, 2)
DebugHelper.show(struct, 'My simple struct')
```

The output shows details of the struct.

```show.yaml```:
```yaml
---
MyStruct (size=3 name=My simple struct):
  Member 0:
    Name: :a
    Value: 0 (Fixnum)
  Member 1:
    Name: :b
    Value: 1 (Fixnum)
  Member 2:
    Name: :c
    Value: 2 (Fixnum)
```

#### Mixed Struct

This example shows a struct of mixed values.

```show.rb```:
```ruby
require 'debug_helper'

MyStruct = Struct.new(:a, :b, :c)
struct = MyStruct.new(0, 'one', :two)
DebugHelper.show(struct, 'My mixed struct')
```

The output shows details of the struct.

```show.yaml```:
```yaml
---
MyStruct (size=3 name=My mixed struct):
  Member 0:
    Name: :a
    Value: 0 (Fixnum)
  Member 1:
    Name: :b
    Value:
      String (size=3 encoding=UTF-8):
      - one
  Member 2:
    Name: :c
    Value:
      Symbol (size=3): :two
```

#### Nested Structs

This example shows nested structs.

```show.rb```:
```ruby
require 'debug_helper'

MyStruct = Struct.new(:a, :b, :c)
struct_0 = MyStruct.new(0, 1, 2)
struct_1 = MyStruct.new(3, 4, 5)
struct_0.a = struct_1
DebugHelper.show(struct_0, 'My nested struct')
```

The output shows details of the structs.

```show.yaml```:
```yaml
---
MyStruct (size=3 name=My nested struct):
  Member 0:
    Name: :a
    Value:
      MyStruct (size=3):
        Member 0:
          Name: :a
          Value: 3 (Fixnum)
        Member 1:
          Name: :b
          Value: 4 (Fixnum)
        Member 2:
          Name: :c
          Value: 5 (Fixnum)
  Member 1:
    Name: :b
    Value: 1 (Fixnum)
  Member 2:
    Name: :c
    Value: 2 (Fixnum)
```

#### Circular Structs

This example shows structs that make a circular reference.

```show.rb```:
```ruby
require 'debug_helper'

MyStruct = Struct.new(:a, :b, :c)
struct_0 = MyStruct.new(0, 1, 2)
struct_1 = MyStruct.new(3, 4, 5)
struct_0.a = struct_1
struct_1.a = struct_0
DebugHelper.show(struct_0, 'My circular struct')
```

The output shows details of the structs.

The circular reference is not followed.

```show.yaml```:
```yaml
---
MyStruct (size=3 name=My circular struct):
  Member 0:
    Name: :a
    Value:
      MyStruct (size=3):
        Member 0:
          Name: :a
          Value: "#<struct MyStruct a=#<struct MyStruct a=#<struct MyStruct:...>,
            b=4, c=5>, b=1, c=2> (MyStruct)"
        Member 1:
          Name: :b
          Value: 4 (Fixnum)
        Member 2:
          Name: :c
          Value: 5 (Fixnum)
  Member 1:
    Name: :b
    Value: 1 (Fixnum)
  Member 2:
    Name: :c
    Value: 2 (Fixnum)
```
### String
### Symbol
