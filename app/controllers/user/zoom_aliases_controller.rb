class User::ZoomAliasesController < User::BaseController
  def update
    zoom_alias = ZoomAlias.find(params[:id])
    student = zoom_alias.student
    zoom_alias.update(zoom_alias_params)
    redirect_to student
  end

  def zoom_alias_params
    params.require(:zoom_alias).permit(:student_id)
  end
end