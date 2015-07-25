#encoding: UTF-8
namespace :ls_gen do
  desc "Lists generator"
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
  
  task competition_lists: :environment do
    require 'prawn/table'
    campaign = Campaign.find(3)
    competition_items = campaign.competition_items
    target_organizations = campaign.target_organizations.uniq
    applications_hash = Application.competition_lists(campaign)
    competition_items.each do |i|
      applications = applications_hash.select{|a, h| h[:competitions].include?(i.id)}
      unless applications.empty?
        title = "#{i.name} (конкурсный список на #{Time.now.to_s})"
        pdf = Prawn::Document.new(page_size: "A3", page_layout: :landscape, :info => {
                                  :Title => title,
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
        pdf.text i.name, :style => :bold, :size => 14
        unless i.name =~ /целев/
          data = [["№", "Номер дела", "Ф.И.О.", "Химия", "Биология", "Русский язык", "Сумма", "ИД", "Конкурсный балл", "Оригинал", "Приоритет этого конкурса"]]
          n = 0
          applications.each do |a, h|
            n += 1
            data += [[n.to_s + ".", "%04d" % a.application_number, [a.entrant_last_name, a.entrant_first_name, a.entrant_middle_name].compact.join(" "), h[:chemistry], h[:biology], h[:russian], h[:summa], h[:achievement] == 10 ? h[:achievement] : '', h[:full_summa], h[:original_received] ? "+" : "", h[:competitions].index(i.id) + 1]]
          end
          pdf.table(data, header: true)
          string = "Страница" + " <page> " + "из" + " <total>"
          options = {:at => [pdf.bounds.right - 100, 0], :width => 150, :align => :center, :start_count_at => 1, :size => 12}
          pdf.number_pages string, options
          pdf.render_file "public/#{title}"
        else
          target_organizations.each do |t|
            target_applications = applications.select{|a, h| a[:target_organization_id] == t.id}
            unless target_applications.empty?
              pdf.text t.target_organization_name, :style => :bold, :size => 12
              data = [["№", "Номер дела", "Ф.И.О.", "Химия", "Биология", "Русский язык", "Сумма", "ИД", "Конкурсный балл", "Оригинал", "Приоритет этого конкурса"]]
              n = 0
              target_applications.each do |a, h|
                n += 1
                data += [[n.to_s + ".", "%04d" % a.application_number, [a.entrant_last_name, a.entrant_first_name, a.entrant_middle_name].compact.join(" "), h[:chemistry], h[:biology], h[:russian], h[:summa], h[:achievement], h[:full_summa], h[:original_received] ? "+" : "", h[:competitions].index(i.id) + 1]]
              end
              pdf.table(data, header: true)
              pdf.move_down 10
            end
          end
        string = "Страница" + " <page> " + "из" + " <total>"
        options = {:at => [pdf.bounds.right - 100, 0], :width => 150, :align => :center, :start_count_at => 1, :size => 12}
        pdf.number_pages string, options
        pdf.render_file "public/#{title}"
        end
      end
    end
          
  end

end