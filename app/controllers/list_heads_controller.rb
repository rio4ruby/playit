class ListHeadsController < ApplicationController
  layout 'appfluid'
  before_filter :authenticate_user!

  def index
    @list_heads = ListHead.my(current_user).page(params[:page]).per(15)
  end

  # GET /list_heads/new
  # GET /list_heads/new.json
  def new
    @list_head = ListHead.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @list_head }
    end
  end

  # GET /list_heads/1/edit
  def edit
    @list_head = ListHead.find(params[:id])
  end

  # POST /list_heads
  # POST /list_heads.json
  def create
    @list_head = ListHead.new(params[:list_head])
    @list_head.user = current_user

    respond_to do |format|
      if @list_head.save
        ListNode.create!(:listable => @list_head)
        format.html { redirect_to @list_head, notice: 'List head was successfully created.' }
        format.json { render json: @list_head, status: :created, location: @list_head }
      else
        format.html { render action: "new" }
        format.json { render json: @list_head.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /list_heads/1
  # PUT /list_heads/1.json
  def update
    @list_head = ListHead.find(params[:id])

    respond_to do |format|
      if @list_head.update_attributes(params[:list_head])
        format.html { redirect_to @list_head, notice: 'List head was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @list_head.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /list_heads/1
  # DELETE /list_heads/1.json
  def destroy
    @list_head = ListHead.find(params[:id])
    @list_head.destroy

    respond_to do |format|
      format.html { redirect_to list_heads_url }
      format.json { head :ok }
    end
  end



end
