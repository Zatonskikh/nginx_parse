require 'time'
require 'active_support/all'

class NginxParser
  def initialize(log_file)
    @log_file = File.open(log_file).readlines
  end

  def read_lines
    dict = {}
    valid_lines = 0
    x_resp_time = 0.0
    @log_file.each do |line|
      pretty_date = pretty_date(line)
      next unless (Time.now - Time.parse(pretty_date)) / 1.hour < 24
      valid_lines += 1
      pretty_status = pretty_status(line)
      dict.key?(pretty_status) ? dict[pretty_status] += 1 : dict[pretty_status] = 1
      next unless pretty_status.equal?(200)
      x_resp_time += pretty_time(line)
    end
    print pretty_output(valid_lines, dict, x_resp_time)
  end

  # @return [formatted statuses]
  # @param [hash of statuses]
  def pretty_statuses(statuses)
    result = ''
    statuses.each do |key, value|
      result += "#{key} - #{value}\n"
    end
    result
  end

  def pretty_date(line)
    result = line
             .to_s
             .scan(%r{\d{1,2}\/[a-zA-Z]+\/\d{4}.\d{2}.\d{2}.\d{2}\s.\d{4}})
             .last
    result[':'] = ' '
    result
  end

  def pretty_status(line)
    line
      .to_s.scan(/up_status=\D\d{3}/).last.split(/="/)[1]
      .to_i
  end

  def pretty_time(line)
    line
      .to_s
      .scan(/req_time=\D\d.\d{3}/).last.split(/="/)[1]
      .to_d
  end

  def pretty_output(valid_lines, dict, x_resp_time)
    "#{valid_lines - dict[200]} out of #{valid_lines}"\
          " requests returned non 200 code:\n" +
      pretty_statuses(dict).to_s +
      'Average response with 200 code:'\
        "#{(x_resp_time / dict[200] * 1000).to_i}"\
        "ms from #{valid_lines} requests."
  end
end

NginxParser.new('log.txt').read_lines if $PROGRAM_NAME == __FILE__