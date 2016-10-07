class Todo::Create < Trailblazer::Operation

  # Logic for creating a TODO
  #     if `todo_list` is specified
  #         create the `todo`
  #         associated with `todo_list`
  #     else
  #         create the `todo`
  #         create a `user`
  #         create a default `todo_list`
  #         associate `todo_list` with `user`
  #         associate `todo` with `todo_list`
  def process(params)
    # make sure title is not blank
    if params[:todo][:title].blank?
      return invalid!
    else
      # build the todo
      todo = Todo.new(params.require(:todo).permit(:title, :descriptioin))
      # find or create the parent list for the todo
      if params[:todo_list_id].present?
        todo_list = TodoList.find(params[:todo_list_id])
      else
        todo_list = TodoList.find_by(name: "Default To-Do List")
        if todo_list.blank?
          todo_list = TodoList.create!(name: "Default To-Do List")
        end
        # Find or create the owner of the todo_list:
        ##### If current_user_id is present, fetch that user
        ##### otherwise, create a new one
        current_user = params[:current_user]
        if params[:current_user].nil?
          if params[:curent_user_id].nil?
            current_user = User.create!(fullname: "Guest")
          else
            current_user = User.find(params[:current_user_id])
          end
        end
        # assign the todo_list to the user
        todo_list.user = current_user
        todo_list.save!
      end
      # associate the todo with the todo_list
      todo.list = todo_list
      todo.save!
    end
  end
end
