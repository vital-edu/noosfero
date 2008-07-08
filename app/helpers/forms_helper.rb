module FormsHelper

  def generate_form( name, obj, fields={} )
    labelled_form_for name, obj do |f|
      f.text_field(:name)
    end
  end

  def labelled_radio_button( human_name, name, value, checked = false, options = {} )
    options[:id] ||= 'radio-' + FormsHelper.next_id_number
    radio_button_tag( name, value, checked, options ) +
    content_tag( 'label', human_name, :for => options[:id] )
  end

  def labelled_check_box( human_name, name, value = "1", checked = false, options = {} )
    options[:id] ||= 'checkbox-' + FormsHelper.next_id_number
    check_box_tag( name, value, checked, options ) +
    content_tag( 'label', human_name, :for => options[:id] )
  end

  def labelled_text_field( human_name, name, value=nil, options={} )
    options[:id] ||= 'text-field-' + FormsHelper.next_id_number
    content_tag('label', human_name, :for => options[:id]) +
    text_field_tag( name, value, options )
  end

  def labelled_select( human_name, name, value_method, text_method, selected, collection, options )
    options[:id] ||= 'select-' + FormsHelper.next_id_number
    content_tag('label', human_name, :for => options[:id]) +
    select_tag( name, options_from_collection_for_select(collection, value_method, text_method, selected), options)
  end

  def submit_button(type, label, html_options = {})
    bt_cancel = html_options[:cancel] ? button(:cancel, _('Cancel'), html_options[:cancel]) : ''

    html_options[:class] = [html_options[:class], 'submit'].compact.join(' ')

    the_class = "button with-text icon-#{type}"
    if html_options.has_key?(:class)
      the_class << ' ' << html_options[:class]
    end

    bt_submit = submit_tag(label, html_options.merge(:class => the_class))

    bt_submit + bt_cancel
  end

  def text_field_with_local_autocomplete(name, choices, html_options = {})
    id = html_options[:id] || name

    text_field_tag(name, '', html_options) +
    content_tag('div', '', :id => "autocomplete-for-#{id}", :class => 'auto-complete', :style => 'display: none;') +
    javascript_tag('new Autocompleter.Local(%s, %s, %s)' % [ id.to_json, "autocomplete-for-#{id}".to_json, choices.to_json ] )
  end

protected
  def self.next_id_number
    if defined? @@id_num
      @@id_num.next!
    else
      @@id_num = '0'
    end
  end
end

