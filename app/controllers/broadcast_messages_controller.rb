class BroadcastMessagesController < ApplicationController
  before_action :set_broadcast_message, only: %i[ show edit update destroy send_sms ]

  # GET /broadcast_messages or /broadcast_messages.json
  def index
    @broadcast_messages = BroadcastMessage.all.order(created_at: :desc)
    @broadcast_message = BroadcastMessage.new
  end

  # GET /broadcast_messages/1 or /broadcast_messages/1.json
  def show
  end

  # GET /broadcast_messages/new
  def new
    @broadcast_message = BroadcastMessage.new
  end

  # GET /broadcast_messages/1/edit
  def edit
  end

  # POST /broadcast_messages or /broadcast_messages.json
  def create
    @broadcast_message = BroadcastMessage.new(broadcast_message_params)

    respond_to do |format|
      if @broadcast_message.save
        format.html { redirect_to broadcast_message_url(@broadcast_message), notice: "Broadcast message was successfully created." }
        format.turbo_stream { render turbo_stream: turbo_stream.prepend("broadcast_messages", partial: "broadcast_messages/broadcast_message", locals: { broadcast_message: @broadcast_message }) }
        format.json { render :show, status: :created, location: @broadcast_message }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@broadcast_message, partial: "broadcast_messages/form", locals: { broadcast_message: @broadcast_message }) }
        format.json { render json: @broadcast_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /broadcast_messages/1 or /broadcast_messages/1.json
  def update
    respond_to do |format|
      if @broadcast_message.update(broadcast_message_params)
        format.html { redirect_to broadcast_message_url(@broadcast_message), notice: "Broadcast message was successfully updated." }
        format.json { render :show, status: :ok, location: @broadcast_message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @broadcast_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /broadcast_messages/1 or /broadcast_messages/1.json
  def destroy
    @broadcast_message.destroy!

    respond_to do |format|
      format.html { redirect_to broadcast_messages_url, notice: "Broadcast message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def send_sms
    BulkSendSms.new(broadcast_message_id: @broadcast_message.id).call

    respond_to do |format|
      format.html { redirect_to broadcast_messages_url, notice: "Request to send SMS is being processed ..." }
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@broadcast_message, partial: "broadcast_messages/broadcast_message", locals: { broadcast_message: @broadcast_message }, notice: "Request to send SMS is being processed ...") }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_broadcast_message
      @broadcast_message = BroadcastMessage.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def broadcast_message_params
      params.require(:broadcast_message).permit(:message)
    end
end
