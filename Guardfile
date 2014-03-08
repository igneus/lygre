
guard :rspec do
  #watch(%r{^spec/.+_spec\.rb$})
  #watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+\.rb$}) { 'spec' }
  watch(%r{^lib/(.+)\.treetop$})     { 'spec' }
  watch(%r{^lib/(.+)\.rb$})     { 'spec' }
  watch('spec/spec_helper.rb')  { 'spec' }
end

