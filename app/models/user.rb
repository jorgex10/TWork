class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :comments
  has_many :user_has_groups
  has_many :file_tasks, dependent: :destroy
  has_many :tasks, through: :assigned_tasks
  has_many :assigned_tasks, through: :user_has_groups

  def name
    "#{first_name} #{last_name}"
  end

  def self.search_name query, group = nil
    unless group
      if query
        where('first_name || last_name ILIKE ?', "%#{query}%")
      else
        all
      end
    else
      request = []
      entities = UserHasGroup.where work_group_id: group
      entities.each do |entity|
        where('first_name || last_name ILIKE ?', "%#{query}%").each do |w|
          if w.name == User.find(entity.user_id).name
            request << w
            return request
          end
        end
      end
    end
  end

  def self.assigned_members task
    members = []
    task.assigned_tasks.each do |a|
      members << a.user_has_group.user
    end
    return members
  end

end
