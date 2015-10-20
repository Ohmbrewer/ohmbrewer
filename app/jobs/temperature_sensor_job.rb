class TemperatureSensorJob < ParticleJob
  queue_as :temp

  attr_accessor :temp_id, :task

  # Temperature Sensor tasks.
  # Right now they're analogous to the sensor "state". When this job is refactored,
  # references to "tasks" should be removed and we can move the contents of #send_task into
  # the body of #perform
  SUPPORTED_TASKS = [:on, :off]

  # TODO: [After Demos] Refactor the temperature sensor job to react to commands from the Scheduler. Should make things simpler, actually
  # Sets up the TemperatureSensorJob. Current handled arguments specific to this job type are:
  # * +:temp_id+ The ID of the Temperature Sensor connected to the Rhizome that we wish to control
  # * +:task+ The type of Temperature Sensor task we'd like to do. Currently, this is either :on or :off.
  # @param [Hash] arguments Arguments for setting up the job
  def initialize(*arguments)
    super
    Rails.logger.info "Args is: #{arguments.inspect}"
    params = temp_params(*arguments)
    @temp_id ||= params[:temp_id]
    @task ||= params[:task].to_sym
  end

  def perform(*args)
    raise ArgumentError, 'No temperature sensor selected!' if temp_id.nil? || temp_id.empty?

    if @task.present?
      case @task
        when :on
          minute_from_now = Time.now + 60
          send_task({
                        id: temp_id,
                        state: 'on',
                        stop_time: minute_from_now.to_i
                    })
        when :off
          send_task({
                        id: temp_id,
                        state: 'off'
                    })
        else
          raise ArgumentError, "Invalid TemperatureSensorJob test type supplied (#{@task})! Available options are #{SUPPORTED_TASKS}"
      end
    end
  end

  private

    def send_task(task_hash)
      temp_args = self.class.to_particle_args(task_hash)
      Rails.logger.info "Sending a temperature sensor message of: #{temp_args}"
      begin
        @particle.function :temps, temp_args
      rescue Particle::BadRequest => e
        msg = "Lost contact with Rhizome or the Rhizome doesn't support temperature sensing! Check your equipment!"
        Rails.logger.error msg
      end
    end

    def temp_params(*args)
      args.to_h
          .symbolize_keys
          .slice(:id, :temp_id, :task)
    end

end