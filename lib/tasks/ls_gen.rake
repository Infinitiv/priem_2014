#encoding: UTF-8
namespace :ls_gen do
  desc "List generator"
  task app_list: :environment do
    h = {}
    campaign = Campaign.find(3)
    competition_items = campaign.competition_items
    competition_items.each do |i|
      data = i.applications.where(last_deny_day: nil).select(:application_number, :entrant_last_name, :entrant_first_name, :entrant_middle_name).sort_by(&:entrant_first_name).sort_by(&:entrant_last_name)
      h[i.name] = data unless data.empty?
    end
    pdf = Prawn::Document.new(page_size: "A4", :info => {
      :Title => 'Список поступающих на ' + Time.now.to_date.to_s,
      :Creator => "ISMA",
      :Producer => "Prawn",
      :CreationDate => Time.now }
      )
    pdf.font_families.update("Ubuntu" => {
      :normal => "#{Rails.root}/vendor/fonts/Ubuntu-R.ttf",
      :italic => "#{Rails.root}/vendor/fonts/Ubuntu-RI.ttf",
      :bold => "#{Rails.root}/vendor/fonts/Ubuntu-B.ttf"
                                      })
    pdf.font "Ubuntu"
    h.each do |i, apps|
      pdf.text i, :style => :bold, :size => 10
      pdf.move_down 6
      n = 0
      apps.each do |app|
        n += 1
        pdf.text [n.to_s + ".", "%04d" % app.application_number, app.entrant_last_name, app.entrant_first_name, app.entrant_middle_name].compact.join(" "), :size => 6
        pdf.move_down 2
      end
      pdf.start_new_page
    end
    string = "Страница" + " <page> " + "из" + " <total>"
    options = {:at => [pdf.bounds.right - 100, 0], :width => 150, :align => :center, :start_count_at => 1, :size => 6}
    pdf.number_pages string, options
    pdf.render_file 'public/app_list'
  end

end