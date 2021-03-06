require 'diff-lcs'
require 'ostruct'
require 'pathname'
require 'set'
require 'tempfile'
require 'yaml'

require "test_helper"

TEST_DIR_PATH = File.dirname(__FILE__)

class DebugHelperTest < Minitest::Test

  include DebugHelper::Putd

  def test_version
    refute_nil ::DebugHelper::VERSION
  end

  # Classes to exercise :kind_of? in handler selection.
  class ArraySub < Array; end
  class DirSub < Dir; end
  class ExceptionSub < Exception; end
  class FileSub < File; end
  class IOSub < IO; end
  class HashSub < Hash; end
  class OpenStructSub < OpenStruct; end
  class RangeSub < Range; end
  class SetSub < Set; end
  class StringSub < String; end
  class StructSub < Struct; end
  # There's no method Symbol.new, so cannot instantiate a subclass.
  # class SymbolSub < Symbol; end

  MyStruct = Struct.new(:foo, :bar, :baz)
  MyStructSub = StructSub.new(:foo, :bar, :baz)

  def test_show

    array_self_referencing = []
    array_self_referencing.push(array_self_referencing)

    array_circular_0 = []
    array_circular_1 = []
    array_circular_0.push(array_circular_1)
    array_circular_1.push(array_circular_0)

    hash_self_referencing_key = {}
    hash_self_referencing_key.store(hash_self_referencing_key, 0)

    hash_self_referencing_value = {}
    hash_self_referencing_value.store(:a, hash_self_referencing_value)

    hash_circular_key_0 = {}
    hash_circular_key_1 = {}
    hash_circular_key_0.store(hash_circular_key_1, 0)
    hash_circular_key_0.store(hash_circular_key_0, 0)

    hash_circular_value_0 = {}
    hash_circular_value_1 = {}
    hash_circular_value_0.store(:a, hash_circular_value_1)
    hash_circular_value_1.store(:b, hash_circular_value_0)

    ostruct_self_referencing = OpenStruct.new
    ostruct_self_referencing.a = ostruct_self_referencing

    ostruct_circular_0 = OpenStruct.new
    ostruct_circular_1 = OpenStruct.new
    ostruct_circular_0.a = ostruct_circular_1
    ostruct_circular_1.a = ostruct_circular_0

    set_self_referencing = Set.new([])
    set_self_referencing.add(set_self_referencing)

    set_circular_0 = Set.new([])
    set_circular_1 = Set.new([])
    set_circular_0.add(set_circular_1)
    set_circular_1.add(set_circular_0)

    string_multiline = <<EOT
foobar
snafu
janfu
EOT

    struct_self_referencing = MyStruct.new(0, 1, 2)
    struct_self_referencing.foo = struct_self_referencing

    struct_circular_0 = MyStruct.new(0, 1, 2)
    struct_circular_1 = MyStruct.new(0, 1, 2)
    struct_circular_0.foo = struct_circular_1
    struct_circular_1.bar = struct_circular_0

    {
        :test_array => [14, 22],
        :test_array_empty => [],
        :test_array_mixed_values => [14, 'foo', [0, 1], {:a => 1, :b => 1}, true, nil],
        :test_array_self_referencing => array_self_referencing,
        :test_array_circular => array_circular_0,

        :test_array_sub => ArraySub.new([0, 1, 2]),

        :test_dir => Dir.new(File.dirname(__FILE__)),

        :test_dir_sub => DirSub.new(File.dirname(__FILE__)),

        :test_hash => {:a => 14, :b => 22},
        :test_hash_empty => {},
        :test_hash_mixed_keys => {14 => 0, :a => 1, 'foobar' => 2},
        :test_hash_mixed_values => {:a => 0, :b => '0', :c => nil},
        :test_hash_self_referencing_key => hash_self_referencing_key,
        :test_hash_self_referencing_value => hash_self_referencing_value,
        :test_hash_circular_key => hash_circular_key_0,
        :test_hash_circular_value => hash_circular_value_0,

        :test_hash_sub => HashSub.new.merge(:a => 0, :b => 1),

        :test_io => IO.new(IO.sysopen(__FILE__, 'r'), 'r'),

        :test_io_sub => IOSub.new(IO.sysopen(__FILE__, 'r'), 'r'),

        :test_match_data => /(?<a>.)(?<b>.)/.match("01"),

        :test_ostruct => OpenStruct.new(:a => 0, :b => 1, :c => 2),
        :test_ostruct_empty => OpenStruct.new,
        :test_ostruct_mixed_values => OpenStruct.new(:a => 0, :b => 'one', :c => :two),
        :test_ostruct_self_referencing => ostruct_self_referencing,
        :test_ostruct_circular => ostruct_circular_0,

        :test_ostruct_sub => OpenStructSub.new(:a => 0, :b => 1, :c => 2),

        :test_range_include_end => (0..4),
        :test_range_exclude_end => (0...4),

        :test_range_sub => RangeSub.new(0, 4),

        :test_regexp => /(?<a>.)(?<b>.)/,

        :test_set => Set.new([14, 22]),
        :test_set_empty => Set.new([]),
        :test_set_mixed_values => Set.new([14, 'foo', [0, 1], {:a => 1, :b => 1}, true, nil]) ,
        :test_set_self_referencing => set_self_referencing,
        :test_set_circular => set_circular_0,

        :test_set_sub => SetSub.new([14, 22]),

        :test_string => 'Lorem ipsum',
        :test_string_empty => '',
        :test_string_multiline => string_multiline,
        :test_string_iso_8859 => 'Lorem ipsum'.encode(Encoding::ISO_8859_1),

        :test_string_sub => StringSub.new('Lorem ipsum'),

        :test_struct => MyStruct.new(0, 1, 2),
        :test_struct_self_referencing => struct_self_referencing,
        :test_struct_circular => struct_circular_0,

        :test_struct_sub => MyStructSub.new(0, 1, 2),

        :test_symbol => :lorem_ipsum,

    }.each_pair do |name, obj|
      _test_show_object(self, obj, name)
    end

  end

  def test_depth
    {
        :test_depth_default => {
            :options => {},
            :obj => {
                :a => {
                    :b => {
                        :c => 'ok',
                    }
                }
            }
        },
        :test_depth_prune => {
            :options => {},
            :obj => {
                :a => {
                    :b => {
                        :c => {
                            :d => 'not ok'
                        }
                    }
                }
            }
        },
        :test_depth_1 => {
            :options => {:depth => 1},
            :obj => {
                :a => {
                    :b => {
                        :c => 'not ok',
                    }
                }
            }
        }
    }.each_pair do |name, h|
      options = h[:options]
      obj = h[:obj]
      _test_show_object(self, obj, name, options)
    end
  end

  def _test_show(test, method, name)
    expected_file_path = File.join(
        TEST_DIR_PATH,
        'show',
        'expected',
        "#{name.to_s}.txt",
    )
    expected_data = File.read(expected_file_path)
    conditioned_data = expected_data.gsub('git_dir', DebugHelperTest.git_clone_dir_path)
    conditioned_file = Tempfile.new("#{name.to_s}.txt")
    conditioned_file.write(conditioned_data)
    conditioned_file.close
    actual_file_path = File.join(
        TEST_DIR_PATH,
        'show',
        'actual',
        "#{name.to_s}.txt",
    )
    yield actual_file_path
    diffs = DebugHelperTest.diff_files(conditioned_file.path, actual_file_path)
    message = "Test for #{method} with item '#{name}' failed"
    test.assert_empty(diffs, message)
  end

  def _test_show_object(test, obj, name, options = {})
    _test_show(test, :show, name) do |actual_file_path|
      DebugHelperTest.write_stdout(actual_file_path) do
        DebugHelper.send(:show, obj, name, options)
      end
    end
    _test_show(test, :putd, name) do |actual_file_path|
      DebugHelperTest.write_stdout(actual_file_path) do
        putd(obj, name, options)
      end
    end
  end

  def test_show_exception
    def clean_file_for_exception(exception_class_name, actual_file_path)
      yaml = YAML.load_file(actual_file_path)
      top_key = yaml.keys.first
      values = yaml.fetch(top_key)
      backtrace = values.delete("#{exception_class_name}#backtrace")
      assert_match(File.basename(__FILE__), backtrace.first)
      yaml.store(top_key, values)
      File.write(actual_file_path, YAML.dump(yaml))
    end
    {
        :test_exception => Exception,
        :test_exception_sub => ExceptionSub,
    }.each_pair do |name, klass|
      exception = nil
      begin
        raise klass.new('Boo!')
      rescue klass => exception
        # It's saved.
      end
      _test_show(self, :show, name) do |actual_file_path|
        DebugHelperTest.write_stdout(actual_file_path) do
          DebugHelper.send(:show, exception, name)
        end
        clean_file_for_exception(exception.class.name, actual_file_path)
        _test_show(self, :putd, name) do |act_file_path|
          DebugHelperTest.write_stdout(act_file_path) do
            putd(exception, name)
          end
          clean_file_for_exception(exception.class.name, actual_file_path)
        end
      end
    end
  end

  def test_show_object
    # To remove volatile values from the captured output.
    def clean_file_for_object(actual_file_path)
      yaml = YAML.load_file(actual_file_path)
      top_key = yaml.keys.first
      values = yaml.fetch(top_key)
      # Object ID.
      {
          :object_id => /^\d+$/,
      }.each_pair do |key_prefix, regexp|
        values.keys.each do |key|
          next unless key.start_with?("Object##{key_prefix}")
          value = values.delete(key.to_s).to_s
          assert_match(regexp, value)
          break
        end
      end
      yaml.store(top_key, values)
      File.write(actual_file_path, YAML.dump(yaml))
    end
    name = 'test_object'
    object = Object.new
    _test_show(self, :show, name) do |actual_file_path|
      DebugHelperTest.write_stdout(actual_file_path) do
        DebugHelper.send(:show, object, name)
      end
      clean_file_for_object(actual_file_path)
    end
    _test_show(self, :putd, name) do |actual_file_path|
      DebugHelperTest.write_stdout(actual_file_path) do
        putd(object, name)
      end
      clean_file_for_object(actual_file_path)
    end
  end

  def test_show_file
    # To remove volatile values from the captured output.
    def clean_file_for_file(class_name, actual_file_path, test_file_path)
      yaml = YAML.load_file(actual_file_path)
      top_key = yaml.keys.first
      values = yaml.fetch(top_key)
      # Paths.
      {
          :absolute_path => /^#{test_file_path}$/,
          :path => /^#{test_file_path}$/,
          :realpath => /^#{test_file_path}$/,
      }.each_pair do |key_prefix, regexp|
        values.keys.each do |key|
          next unless key.start_with?("#{class_name}.#{key_prefix}(")
          value = values.delete(key.to_s)
          assert_match(regexp, value)
          break
        end
      end
      # Times.
      %w/
          atime
          ctime
          mtime
        /.each do |key_prefix|
        values.keys.each do |key|
          next unless key.start_with?("#{class_name}.#{key_prefix}(")
          value = values.delete(key)
          assert_instance_of(Time, value)
          break
        end
      end
      #  Size.
      values.keys.each do |key|
        next unless key.start_with?("#{class_name}.size(")
        value = values.delete(key)
        assert_equal(File.size(test_file_path), value)
        break
      end
      yaml.store(top_key, values)
      File.write(actual_file_path, YAML.dump(yaml))
    end
    {
        :test_file => File,
        :test_file_sub => DebugHelperTest::FileSub,
    }.each_pair do |name, klass|
      file_path = __FILE__
      file = klass.new(file_path)
      _test_show(self, :show, name) do |actual_file_path|
        DebugHelperTest.write_stdout(actual_file_path) do
          DebugHelper.send(:show, file, name)
        end
        clean_file_for_file(klass.name, actual_file_path, file_path)
      end
      _test_show(self, :putd, name) do |actual_file_path|
        DebugHelperTest.write_stdout(actual_file_path) do
          putd(file, name)
        end
        clean_file_for_file(klass.name, actual_file_path, file_path)
      end
    end
  end

  def self.write_stdout(file_path)
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    File.write(file_path, $stdout.string)
  ensure
    $stdout = old_stdout
  end

  def self.diff_files(expected_file_path, actual_file_path)
    diffs = nil
    File.open(expected_file_path) do |expected_file|
      expected_lines = expected_file.readlines
      File.open(actual_file_path) do |actual_file|
        actual_lines = actual_file.readlines
        diffs = Diff::LCS.diff(expected_lines, actual_lines)
      end
    end
    diffs
  end

  def self.git_clone_dir_path
    git_dir = `git rev-parse --git-dir`.chomp
    unless $?.success?
      message = <<EOT

This test must run inside a .git project.
That is, the working directory one of its parents must be a .git directory.
EOT
      raise RuntimeError.new(message)
    end
    if git_dir == '.git'
      path = `pwd`.chomp
    else
      path = File.dirname(git_dir).chomp
    end
    realpath = Pathname.new(path.sub(%r|/c/|, 'C:/')).realpath
    realpath.to_s
  end
end
