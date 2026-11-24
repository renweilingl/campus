class PrintersController < ApplicationController
  before_action :set_printer, only: %i[edit update destroy]

  def index
    # index? 对所有登录用户为真，但 scope 仍只给本人名下的；authorize 显式写出来防以后收严口径漏改
    authorize Printer
    @printers = policy_scope(Printer).order(created_at: :desc)
  end

  def new
    @printer = authorize Printer.new
  end

  def create
    @printer = authorize Printer.new(printer_params)
    # 归属永远取当前登录用户，不接受表单传 user_id
    @printer.user = current_user

    if @printer.save
      redirect_to printers_path, notice: "打印机「#{@printer.name}」已创建"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @printer
  end

  def update
    authorize @printer

    if @printer.update(printer_params)
      redirect_to printers_path, notice: "打印机「#{@printer.name}」已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @printer
    @printer.destroy
    redirect_to printers_path, notice: "打印机已删除"
  end

  private
    def set_printer
      @printer = Printer.find(params[:id])
    end

    def printer_params
      params.expect(printer: %i[brand name code key enabled])
    end
end
