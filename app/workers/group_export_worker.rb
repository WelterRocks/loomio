class GroupExportWorker
  include Sidekiq::Worker

  def perform(group_ids, group_name, actor_id)
    actor = User.find_by!(id:actor_id)
    groups = Group.where(id: group_ids)
    filename = GroupExportService.export(groups, group_name)
    document = Document.create(author: actor, title: filename)
    document.file.attach(io: File.open(filename), filename: filename)
    UserMailer.group_export_ready(actor.id, group_name, document.id).deliver
    document.delay_until(1.week.from_now).destroy!
  end
end
