module Kata
  @@times = []

  def kata txt, lib = nil
    puts txt
    yield if block_given?
    complete
  end

  def requirement txt
    puts indent + txt

    start = Time.now

    yield if block_given?

    rsp = ask "\ncontinue (Y|n): ", 'y'

    puts

    elapsed = Time.now - start
    @@times << {:title => txt, :time => elapsed}

    complete false if rsp.downcase == 'n'
  end

  def example txt
    puts indent + '- ' + txt
  end

  private

  def ask prompt, default
    print prompt
    $stdin.gets.chomp || default
  end

  def complete status = true
    if @@times.size > 0
      title = status ? 'Congratulations!' : 'You completed the following:'

      formatter = lambda do |sec| 
        use = sec.round
        [use/3600, use/60 % 60, use % 60].map {|v| v.to_s.rjust(2,'0')}.join(':')
      end

      puts "\n\n#{title}"
      puts @@times.inject('') {|s,p| s << "- #{p[:title][0,70].ljust(70, ' ')} #{formatter.call(p[:time]).rjust(10,' ')}\n"}
      puts '-' * 70 + ' ' * 5 + '-' * 8
      puts 'Total Time taking Kata'.ljust(70, ' ') + ' ' * 5 + formatter.call(@@times.inject(0) {|s,h| s += h[:time]})
    end

    exit 1 unless status
  end

  def ancestry
    caller.grep(/#{Regexp.escape(__FILE__)}/).map {|v| v.match(/^[^`]*`([^']*)'/)[1]}
  end

  def indent
    nesting = ancestry.size - 2
    ' ' * (3 * nesting)
  end
end

include Kata
