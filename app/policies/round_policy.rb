class RoundPolicy < ApplicationPolicy
  def create?
    user.is_admin_for?(record.group)
  end

  def destroy?
    user.is_admin_for?(record.group)
  end

  def update?
    user.is_admin_for?(record.group)
  end

  def upload?
    user.is_admin_for?(record.group)
  end

  def publish?
    user.is_admin_for?(record.group)
  end
end
