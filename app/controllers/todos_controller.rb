class TodosController < ApplicationController
  include Split::Helper

  before_action :require_login
  before_action :set_todo, only: [:show, :edit, :update, :destroy]

  def index
    @todos = current_user.todos.order(priority: :asc, created_at: :desc)
  end

  def show
  end

  def new
    @todo = current_user.todos.build
  end

  def create
    @todo = current_user.todos.build(todo_params)
    if @todo.save
      ab_finished(:todo_created)
      redirect_to todos_path, notice: "Todo was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @todo.update(todo_params)
      ab_finished(:todo_completed) if todo_params[:completed] == "true" && !@todo.completed_previously_changed?
      redirect_to todos_path, notice: "Todo was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo.destroy
    redirect_to todos_path, notice: "Todo was successfully deleted."
  end

  private

  def set_todo
    @todo = current_user.todos.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :completed, :priority)
  end
end