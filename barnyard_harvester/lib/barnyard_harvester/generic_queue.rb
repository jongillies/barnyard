module BarnyardHarvester

  class GenericQueue

    def initialize(args)
      @queueing = args.fetch(:queueing) { raise "You must provide :queueing" }

      case @queueing
        when :sqs
          require "aws-sdk"
          @sqs_settings = args.fetch(:sqs_settings) { raise "You must provide :sqs_settings" }
          @sqs = AWS::SQS.new(@sqs_settings)
        when :rabbitmq
          require "bunny"
          @rabbitmq_settings = args.fetch(:rabbitmq_settings) { raise "You must provide :rabbitmq_settings" }
          @rabbitmq_settings[:logging] = true if @debug
          @bunny = Bunny.new(@rabbitmq_settings)
          @bunny.start
        when :hash
          @queues = Hash.new
        else
          raise "Unknown queueing method. #{@queuing}"
      end

    end

    def push(queue_name, message)
      case @queueing
        when :sqs
          queue = @sqs.queues.create(queue_name)
          queue.send_message(message)
        when :rabbitmq
          @bunny.queue(queue_name).publish(message)
        when :hash
          @queues[queue_name] = Array.new unless @queues.has_key?(queue_name)
          @queues[queue_name] << message
          File.open("#{queue_name}.yml", "w") { |file| file.puts(@queues[queue_name].to_yaml) }
      end
    end

    def pop(queue_name)
      case @queueing
        when :sqs
          msg = @sqs.queues.create(queue_name).receive_message
          unless msg.nil?
            msg.delete
            msg.body
          else
            nil
          end

        when :rabbitmq
          msg = @bunny.queue(queue_name).pop[:payload]
          if msg == :queue_empty
            return nil
          else
            msg
          end
        when :hash
          msg = @queue.pop
          File.open("#{queue_name}.yml", "w") { |file| file.puts(@queues[queue_name].to_yaml) }
          msg
      end
    end

    def empty(queue_name)
      while pop(queue_name)
      end
    end
  end

end
