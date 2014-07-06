class Request < ActiveRecord::Base
  require 'builder'
  belongs_to :query
  
  def self.data(method, params)
    case method
    when '/dictionary'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
      end
    when '/institutioninfo'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
      end
    when '/validate' || '/import'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
        data.PackageData do |pd|
          campaign_info(pd, params) if params[:campaign_info]
	  admission_info(pd, params) if params[:admission_info]
	  applications(pd, params) if params[:applications]
        end
      end
    when '/import'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
        data.PackageData do |pd|
          campaign_info(pd, params) if params[:campaign_info]
	  admission_info(pd, params) if params[:admission_info]
	  applications(pd, params) if params[:applications]
        end
      end
    when '/delete'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
        data.DataForDelete do |pd|
	  applications_del(pd, params) if params[:applications]
        end
      end
    end
  end
  
  def self.auth_data(root)
    auth_data = ::Builder::XmlMarkup.new(indent: 2)
    a = AuthData.first
    root.AuthData do |ad|
      ad.Login a.login
      ad.Pass a.pass
    end
  end
  
  def self.campaign_info(root, params)
    campaign_info = ::Builder::XmlMarkup.new(indent: 2)
    @c = Campaign.where(id: params[:campaign_id])
    root.CampaignInfo do |ci|
      ci.Campaigns do |ca|
        @c.each do |cm|
          ca.Campaign do |c|
            c.UID cm.id
            c.Name cm.name
            c.YearStart cm.year_start
            c.YearEnd cm.year_end
            cm.education_forms.each do |efm|
              c.EducationForms do |ef|
                ef.EducationFormID efm.education_form_id
              end
            end
            c.StatusID cm.status_id
            c.EducationLevels do |els|
              cm.education_levels.each do |elm|
                els.EducationLevel do |el|
                  el.Course elm.course
                  el.EducationLevelID elm.education_level_id
                end
              end
            end
            c.CampaignDates do |cds|
              cm.campaign_dates.each do |cdm|
                cds.CampaignDate do |cd|
                  cd.UID cdm.id
                  cd.Course cdm.course
                  cd.EducationLevelID cdm.education_level_id
                  cd.EducationFormID cdm.education_form_id
                  cd.EducationSourceID cdm.education_source_id
                  cd.Stage cdm.stage if cdm.stage
                  cd.DateStart cdm.date_start
                  cd.DateEnd cdm.date_end
                  cd.DateOrder cdm.date_order
                end
              end
            end
          end
        end
      end
    end
  end

  def self.admission_info(root, params)
    admission_info = ::Builder::XmlMarkup.new(indent: 2)
    @c = AdmissionVolume.where(campaign_id: params[:campaign_id])
    root.AdmissionInfo do |ai|
      ai.AdmissionVolume do |av|
	@c.each do |cm|
	  av.Item do |i|
	    i.UID cm.id
	    i.CampaignUID cm.campaign_id
	    i.EducationLevelID cm.education_level_id
	    i.Course cm.course
	    i.DirectionID cm.direction_id
	    i.NumberBudgetO cm.number_budget_o if cm.number_budget_o
	    i.NumberBudgetOZ cm.number_budget_oz if cm.number_budget_oz
	    i.NumberBudgetZ cm.number_budget_z if cm.number_budget_z
	    i.NumberPaidO cm.number_paid_o if cm.number_paid_o
	    i.NumberPaidOZ cm.number_paid_oz if cm.number_paid_oz
	    i.NumberPaidZ cm.number_paid_z if cm.number_paid_z
	    i.NumberTargetO cm.number_target_o if cm.number_target_o
	    i.NumberTargetOZ cm.number_target_oz if cm.number_target_oz
	    i.NumberTargetZ cm.number_target_z if cm.number_target_z
	    i.NumberQuotaO cm.number_quota_o if cm.number_quota_o
	    i.NumberQuotaOZ cm.number_quota_oz if cm.number_quota_oz
	    i.NumberQuotaZ cm.number_quota_z if cm.number_quota_z	    
	  end
	end
      end
      ai.CompetitiveGroups do |cgs|
	@c = CompetitiveGroup.where(campaign_id: params[:campaign_id]) 
	@c.each do |cm|
	  cgs.CompetitiveGroup do |cg|
	    cg.UID cm.id
	    cg.CampaignUID cm.campaign_id
	    cg.Course cm.course
	    cg.Name cm.name
	    cg.Items do |i|
	      cm.competitive_group_items.each do |cgim|
		i.CompetitiveGroupItem do |cgi|
		  cgi.UID cgim.id
		  cgi.EducationLevelID cgim.education_level_id
		  cgi.DirectionID cgim.direction_id
		  cgi.NumberBudgetO cgim.number_budget_o if cgim.number_budget_o
		  cgi.NumberBudgetOZ cgim.number_budget_oz if cgim.number_budget_oz
		  cgi.NumberBudgetZ cgim.number_budget_z if cgim.number_budget_z
		  cgi.NumberPaidO cgim.number_paid_o if cgim.number_paid_o
		  cgi.NumberPaidOZ cgim.number_paid_oz if cgim.number_paid_oz
		  cgi.NumberPaidZ cgim.number_paid_z if cgim.number_paid_z
		  cgi.NumberQuotaO cgim.number_quota_o if cgim.number_quota_o
		  cgi.NumberQuotaOZ cgim.number_quota_oz if cgim.number_quota_oz
		  cgi.NumberQuotaZ cgim.number_quota_z if cgim.number_quota_z
		end
	      end
	    end
		cg.TargetOrganizations do |tos|
		  cm.target_organizations.each do |tom|
		    tos.TargetOrganization do |to|
		      to.UID tom.id
		      to.TargetOrganizationName tom.target_organization_name
		      to.Items do |i|
			tom.competitive_group_target_items.each do |cgtim|  
			  i.CompetitiveGroupTargetItem do |cgti|
			    cgti.UID cgtim.id
			    cgti.EducationLevelID cgtim.education_level_id
			    cgti.NumberTargetO cgtim.number_target_o if cgtim.number_target_o
			    cgti.NumberTargetOZ cgtim.number_target_oz if cgtim.number_target_oz
			    cgti.NumberTargetZ cgtim.number_target_z if cgtim.number_target_z
			    cgti.DirectionID cgtim.direction_id
			  end
			end
		      end
		    end
		  end
		end
		cg.EntranceTestItems do |etis|
		cm.entrance_test_items.each do |etim|
		  etis.EntranceTestItem do |eti|
		    eti.UID etim.id
		    eti.EntranceTestTypeID etim.entrance_test_type_id
		    eti.Form etim.form
		    eti.MinScore etim.min_score
		    etim.entrance_test_subjects.each do |esm|
		      eti.EntranceTestSubject do |es|
			es.SubjectID esm.subject_id
		      end
		    end
		  end
		end
		end
	  end
	end
      end
    end
  end
  
  def self.applications(root, params)
    applications = ::Builder::XmlMarkup.new(indent: 2)
    @a = Application.where(campaign_id: params[:campaign_id]).where("updated_at > ?", Time.now.to_date - 1)
    root.Applications do |as|
      @a.each do |am|
      as.Application do |a|
	a.UID am.id
	a.ApplicationNumber [am.campaign.year_start, "%04d" % am.application_number].join('-')
	a.Entrant do |e|
	  e.UID am.id
	  e.FirstName am.entrant_first_name
	  e.MiddleName am.entrant_middle_name
	  e.LastName am.entrant_last_name
	  e.GenderID am.gender_id
	end
	a.RegistrationDate am.registration_date.to_datetime
	a.LastDenyDate am.last_deny_day.to_datetime if am.last_deny_day
	a.NeedHostel am.need_hostel
	a.StatusID am.status_id
	a.SelectedCompetitiveGroups do |scg|
	  case am.campaign.year_end
	  when 2013
	    scg.CompetitiveGroupID 1 if am.lech_budget || am.lech_paid
	    scg.CompetitiveGroupID 2 if am.ped_budget || am.ped_paid
	    scg.CompetitiveGroupID 3 if am.stomat_budget || am.stomat_paid
	  when 2014
	    scg.CompetitiveGroupID 4
	  end
	end
	a.SelectedCompetitiveGroupItems do |scgi|
	  case am.campaign.year_end
	  when 2013
	    scgi.CompetitiveGroupItemID 1 if am.lech_budget || am.lech_paid
	    scgi.CompetitiveGroupItemID 2 if am.ped_budget || am.ped_paid
	    scgi.CompetitiveGroupItemID 3 if am.stomat_budget || am.stomat_paid
	  when 2014
	    scgi.CompetitiveGroupItemID 4 unless am.competitions.where(competition_item_id: [1, 4, 7, 10, 13, 16]).empty?
	    scgi.CompetitiveGroupItemID 5 unless am.competitions.where(competition_item_id: [2, 5, 8, 11, 14, 17]).empty?
	    scgi.CompetitiveGroupItemID 6 unless am.competitions.where(competition_item_id: [3, 6, 9, 12, 15, 18]).empty?
	  end
	end
	a.FinSourceAndEduForms do |fsaef|
	  case am.campaign.year_end
	  when 2013
	    if am.lech_budget || am.ped_budget || am.stomat_budget
	      fsaef.FinSourceEduForm do |fsef|
		fsef.FinanceSourceID 14
		fsef.EducationFormID 11
	      end
	    end
	    if am.lech_paid || am.ped_paid || am.stomat_paid
	      fsaef.FinSourceEduForm do |fsef|
		fsef.FinanceSourceID 15
		fsef.EducationFormID 11
	      end
	    end
	    if am.target_organization_id
	      fsaef.FinSourceEduForm do |fsef|
		fsef.FinanceSourceID 16
		fsef.EducationFormID 11
		fsef.TargetOrganizationUID am.target_organization_id
	      end
	    end
	  when 2014
	    am.competitions.each do |competition|
	      fsaef.FinSourceEduForm do |fsef|
		fsef.FinanceSourceID competition.competition_item.finance_source_id if competition.competition_item.finance_source_id
		fsef.EducationFormID 11
		fsef.CompetitiveGroupID competition.competition_item.competitive_group_id if competition.competition_item.competitive_group_id
		fsef.CompetitiveGroupItemID competition.competition_item.competitive_group_item_id if competition.competition_item.competitive_group_item_id
		fsef.Priority competition.priority
		fsef.TargetOrganizationUID am.target_organization_id if am.target_organization_id
	      end
	    end
	  end
	end
	if am.russian || am.chemistry || am.biology
	  case am.campaign.year_end
	  when 2013
	    a.EntranceTestResults do |etrs|
	      if am.russian
		if am.lech_budget || am.lech_paid
		  etrs.EntranceTestResult do |etr|
		    etr.UID 1.to_s + am.application_number.to_s + "russian"
		    etr.ResultValue am.russian
		    etr.ResultSourceTypeID 1
		    etr.EntranceTestSubject do |ets|
		      ets.SubjectID 1
		    end
		    etr.EntranceTestTypeID 1
		    etr.CompetitiveGroupID 1
		  end
		end
		if am.ped_budget || am.ped_paid
		  etrs.EntranceTestResult do |etr|
		    etr.UID 2.to_s + am.application_number.to_s + "russian"
		    etr.ResultValue am.russian
		    etr.ResultSourceTypeID 1
		    etr.EntranceTestSubject do |ets|
		      ets.SubjectID 1
		    end
		    etr.EntranceTestTypeID 1
		    etr.CompetitiveGroupID 2
		  end
		end
		if am.stomat_budget || am.stomat_paid
		  etrs.EntranceTestResult do |etr|
		    etr.UID 3.to_s + am.application_number.to_s + "russian"
		    etr.ResultValue am.russian
		    etr.ResultSourceTypeID 1
		    etr.EntranceTestSubject do |ets|
		      ets.SubjectID 1
		    end
		    etr.EntranceTestTypeID 1
		    etr.CompetitiveGroupID 3
		  end
		end
	      end
	      if am.biology
		if am.lech_budget || am.lech_paid
		  etrs.EntranceTestResult do |etr|
		    etr.UID 1.to_s + am.application_number.to_s + "biology"
		    etr.ResultValue am.biology
		    etr.ResultSourceTypeID 1
		    etr.EntranceTestSubject do |ets|
		      ets.SubjectID 4
		    end
		    etr.EntranceTestTypeID 1
		    etr.CompetitiveGroupID 1
		  end
		end
		if am.ped_budget || am.ped_paid
		  etrs.EntranceTestResult do |etr|
		    etr.UID 2.to_s + am.application_number.to_s + "biology"
		    etr.ResultValue am.biology
		    etr.ResultSourceTypeID 1
		    etr.EntranceTestSubject do |ets|
		      ets.SubjectID 4
		    end
		    etr.EntranceTestTypeID 1
		    etr.CompetitiveGroupID 2
		  end
		end
		if am.stomat_budget || am.stomat_paid
		  etrs.EntranceTestResult do |etr|
		    etr.UID 3.to_s + am.application_number.to_s + "biology"
		    etr.ResultValue am.biology
		    etr.ResultSourceTypeID 1
		    etr.EntranceTestSubject do |ets|
		      ets.SubjectID 4
		    end
		    etr.EntranceTestTypeID 1
		    etr.CompetitiveGroupID 3
		  end
		end
	      end
	      if am.chemistry
		if am.lech_budget || am.lech_paid
		  etrs.EntranceTestResult do |etr|
		    etr.UID 1.to_s + am.application_number.to_s + "chemistry"
		    etr.ResultValue am.chemistry
		    etr.ResultSourceTypeID 1
		    etr.EntranceTestSubject do |ets|
		      ets.SubjectID 11
		    end
		    etr.EntranceTestTypeID 1
		    etr.CompetitiveGroupID 1
		  end
		end
		if am.ped_budget || am.ped_paid
		  etrs.EntranceTestResult do |etr|
		    etr.UID 2.to_s + am.application_number.to_s + "chemistry"
		    etr.ResultValue am.chemistry
		    etr.ResultSourceTypeID 1
		    etr.EntranceTestSubject do |ets|
		      ets.SubjectID 11
		    end
		    etr.EntranceTestTypeID 1
		    etr.CompetitiveGroupID 2
		  end
		end
		if am.stomat_budget || am.stomat_paid
		  etrs.EntranceTestResult do |etr|
		    etr.UID 3.to_s + am.application_number.to_s + "chemistry"
		    etr.ResultValue am.chemistry
		    etr.ResultSourceTypeID 1
		    etr.EntranceTestSubject do |ets|
		      ets.SubjectID 11
		    end
		    etr.EntranceTestTypeID 1
		    etr.CompetitiveGroupID 3
		  end
		end
	      end
	    end
	  when 2014
	    a.EntranceTestResults do |etrs|
	      if am.russian
		etrs.EntranceTestResult do |etr|
		  etr.UID 1.to_s + am.application_number.to_s + 2014.to_s + "russian"
		  etr.ResultValue am.russian
		  etr.ResultSourceTypeID 1
		  etr.EntranceTestSubject do |ets|
		    ets.SubjectID 1
		  end
		  etr.EntranceTestTypeID 1
		  etr.CompetitiveGroupID 4
		end
	      end
	      if am.biology
		etrs.EntranceTestResult do |etr|
		  etr.UID 1.to_s + am.application_number.to_s + 2014.to_s + "biology"
		  etr.ResultValue am.biology
		  etr.ResultSourceTypeID 1
		  etr.EntranceTestSubject do |ets|
		    ets.SubjectID 4
		  end
		  etr.EntranceTestTypeID 1
		  etr.CompetitiveGroupID 4
		end
	      end
	      if am.chemistry
		etrs.EntranceTestResult do |etr|
		  etr.UID 1.to_s + am.application_number.to_s + 2014.to_s + "chemistry"
		  etr.ResultValue am.chemistry
		  etr.ResultSourceTypeID 1
		  etr.EntranceTestSubject do |ets|
		    ets.SubjectID 11
		  end
		  etr.EntranceTestTypeID 1
		  etr.CompetitiveGroupID 4
		end
	      end
	    end
	  end
	end
	a.ApplicationDocuments do |ad|
	  im = am.identity_documents.first
	    ad.IdentityDocument do |id|
	      id.OriginalReceived true
	      id.DocumentSeries im.identity_document_series if im.identity_document_series
	      id.DocumentNumber im.identity_document_number
	      id.DocumentDate im.identity_document_date
	      id.IdentityDocumentTypeID 1
	      id.NationalityTypeID 1
	      id.BirthDate am.birth_date
	    end
	    ad.EduDocuments do |eds|
	      em = am.education_documents.first
	      eds.EduDocument do |ed|
		if em.education_document_type_id == 1
		  ed.SchoolCertificateDocument do |scd|
		    scd.OriginalReceived am.original_received_date ? true : false
		    scd.OriginalReceivedDate am.original_received_date if am.original_received_date
		    scd.DocumentSeries em.education_document_series.to_s
		    scd.DocumentNumber em.education_document_number.to_s
		  end
		else
		  ed.MiddleEduDiplomaDocument do |medd|
		    medd.OriginalReceived am.original_received_date ? true : false
		    medd.OriginalReceivedDate am.original_received_date if am.original_received_date
		    medd.DocumentSeries em.education_document_series.to_s
		    medd.DocumentNumber em.education_document_number.to_s
		  end
		end
	      end
	    end
	  end
      end
      end
    end
  end
  
  def self.applications_del(root, params)
    applications_del = ::Builder::XmlMarkup.new(indent: 2)
    @a = Application.where(campaign_id: params[:campaign_id], status_id: 0)
    root.Applications do |as|
      @a.each do |am|
	as.Application do |a|
	  a.ApplicationNumber [am.campaign.year_start, "%04d" % am.application_number].join('-')
	  a.RegistrationDate am.registration_date.to_datetime
	end
	as.Application do |a|
	  a.ApplicationNumber [am.campaign.year_start, "%04d" % am.application_number].join('-')
	  a.RegistrationDate am.registration_date.to_datetime.to_s.gsub('+00:00', '')
	end
      end
    end
  end
end
