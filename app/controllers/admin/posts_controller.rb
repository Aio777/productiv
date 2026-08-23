# frozen_string_literal: true

class Admin::PostsController < Admin::BaseController
  before_action :set_admin_post, only: %i[show edit update destroy]
  before_action :set_posts_pagination, only: %i[index update]

  def index
    PostsService.update_question_interests(@admin_posts)
  end

  def show; end

  def new
    @admin_post = Post.new
  end

  def edit
    @new_admin_post = Post.new

    @reply = Post.find_by(parent_id: @admin_post.id)
    @parent = Post.find_by(id: @admin_post.parent_id)
  end

  def create
    @admin_post = Post.new(admin_post_params)

    if @admin_post.save
      reload_after_update('Post was successfully created.')
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @admin_post = Post.find(params[:id])
    if @admin_post.update(admin_post_params)
      reload_after_update('Post was successfully updated.')
    else
      @new_admin_post = Post.new
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @reply = Post.find_by(parent_id: @admin_post.id)
    @parent = Post.find_by(id: @admin_post.parent_id)

    @admin_post.destroy!
    @reply.destroy! if @reply.present?
    @parent.update(answer_by_admin: false) if @parent.present?
    reload_after_update('Post was successfully destroyed.')
  end

  private

  def set_admin_post
    @admin_post = Post.find(params.expect(:id))
  end

  def set_posts_pagination
    posts_per_page = 10
    @page = (params[:page] || 1).to_i
    sort = params[:sort].presence || 'interest'

    sort_by = {
      'newest' => { created_at: :desc },
      'oldest' => { created_at: :asc },
      'interest' => { interest_count: :desc }
    }

    all_admin_posts = Post.where(answer_by_admin: false).order(sort_by[sort] || sort_by['interest'])
    @sort = sort
    @total_pages = (Post.where(answer_by_admin: false).count / posts_per_page.to_f).ceil
    @admin_posts = all_admin_posts.limit(posts_per_page).offset((@page - 1) * posts_per_page)
  end

  def admin_post_params
    params.require(:post).permit(:title, :body, :hidden, :answer_by_admin, :reply_id, :parent_id)
  end

  def render_posts_table
    render turbo_stream: [
      turbo_stream.remove('modal'),
      turbo_stream.replace(
        'posts_table',
        partial: 'admin/posts/posts_table',
        locals: {
          page: @page,
          sort: @sort,
          total_pages: @total_pages
        }
      )
    ]
  end

  def redirect_after_update(notice)
    redirect_to admin_posts_path(page: @page, sort: @sort),
                notice: notice,
                status: :see_other
  end

  def reload_after_update(notice)
    set_posts_pagination
    respond_to do |format|
      format.html { redirect_after_update(notice) }
      format.turbo_stream { render_posts_table }
    end
  end
end
