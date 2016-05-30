class ApplicationController < ActionController::Base
  protect_from_forgery


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end



  def elem_id_to_record(elem_id) 
    ary = elem_id.split('-')
    obj_lc,obj_id  = ary[-2],ary[-1]
    cls = obj_lc.camelize.constantize
    id = obj_id.to_i
    cls.find(id)
  end

  def parts_to_rec(obj_lc,obj_id)
    unless obj_lc.blank? || obj_id.blank? || obj_id !~ /^\d+$/
      cls = obj_lc.camelize.constantize
      id = obj_id.to_i
      cls.find(id)
    end
  end

  def elem_id_to_records(elem_id) 
    ary = elem_id.split('-')

    recs = []
    while ary.size >= 2
      idstr = ary.pop
      tbl = ary.pop
      ids = idstr.split(',')
      ids.each do |id|
        if id =~ /^\d+$/
          rec = parts_to_rec(tbl,id)
          recs << rec if rec
        end
      end
    end
    recs.reverse
  end

  def elem_id_to_record2(elem_id) 
    ary = elem_id.split('-')

    recs = []
    ary[-1].split(',').each do |id_str|
      recs << parts_to_rec(ary[-2],id_str)
    end
    ary[-3].split(',').each do |id_str|
      recs << parts_to_rec(ary[-4],id_str)
    end

    recs
  end

  def record_id(idstr)
    idstr.split('-')[-1].to_i if idstr
  end





end
