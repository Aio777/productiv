class RemoveColumnCategoryAssessmentFromRadarRatings < ActiveRecord::Migration[8.0]
  def change
    remove_column :radar_ratings, :category_assessment, :string
  end
end
