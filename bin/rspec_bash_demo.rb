#
# rspec_bash_demo.rb
#

describe "rspec_bash_demo.rb" do

  it "should fail unless I am root" do
    `echo hello world > /bloom.txt`
    dir_glob = Dir.glob("/bloom.txt")
    dir_glob.should == ["/bloom.txt"]
  end

  it "should succeed" do
    `echo hello world > /tmp/bikle.txt`
    dir_glob = Dir.glob("/tmp/bikle.txt")
    dir_glob.should == ["/tmp/bikle.txt"]
  end

end
