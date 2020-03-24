class LogUtil
    def self.elapsed_ms(start)
        ((Time.now - start) * 1000).to_i
    end

    def self.log_elapsed(start, msg)
        Rails.logger.info("#{msg} took #{elapsed_ms(start)} ms")
    end
end