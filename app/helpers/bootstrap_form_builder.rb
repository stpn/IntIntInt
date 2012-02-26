class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
    def button(label, *args)

    # You can also set default options, like a class
    default_class = options[:class] || 'btn'
    @template.button_tag(label.to_s.humanize, :class => default_class)    
  end

end