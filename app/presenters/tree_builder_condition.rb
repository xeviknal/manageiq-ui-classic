class TreeBuilderCondition < TreeBuilder
  private

  def tree_init_options(_tree_name)
    {:full_ids => true}
  end

  def set_locals_for_render
    locals = super
    locals.merge!(:autoload => true)
  end

  # level 0 - root
  def root_options
    {
      :text    => t = _("All Conditions"),
      :tooltip => t
    }
  end

  # not using decorators for now because there are some inconsistencies
  def self.folder_icon(klassname)
    case klassname
    when 'Host'
      'pficon pficon-screen'
    when 'Vm'
      'pficon pficon-virtual-machine'
    when 'ContainerReplicator'
      'pficon pficon-replicator'
    when 'ContainerGroup'
      'fa fa-cubes'
    when 'ContainerNode'
      'pficon pficon-container-node'
    when 'ContainerImage'
      'pficon pficon-image'
    when 'ExtManagementSystem'
      'pficon pficon-server'
    when 'PhysicalServer'
      'pficon pficon-enterprise'
    when 'MiddlewareServer'
      'pficon pficon-middleware'
    end
  end

  # level 1 - host / vm
  def x_get_tree_roots(count_only, _options)
    text_i18n = {:Host                => _("Host Conditions"),
                 :Vm                  => _("VM and Instance Conditions"),
                 :ContainerReplicator => _("Replicator Conditions"),
                 :ContainerGroup      => _("Pod Conditions"),
                 :ContainerNode       => _("Container Node Conditions"),
                 :ContainerImage      => _("Container Image Conditions"),
                 :ExtManagementSystem => _("Provider Conditions"),
                 :PhysicalServer      => _("Physical Infrastructure Conditions"),
                 :MiddlewareServer    => _("Middleware Server Conditions")}

    objects = MiqPolicyController::UI_FOLDERS.collect do |model|
      text = text_i18n[model.name.to_sym]
      icon = self.class.folder_icon(model.to_s)

      {
        :id   => model.name.camelize(:lower),
        :icon => icon,
        :text => text,
        :tip  => text
      }
    end
    count_only_or_objects(count_only, objects)
  end

  # level 2 - conditions
  def x_get_tree_custom_kids(parent, count_only, options)
    assert_type(options[:type], :condition)
    towhat = parent[:id].camelize
    return super unless MiqPolicyController::UI_FOLDERS.collect(&:name).include?(towhat)

    objects = Condition.where(:towhat => towhat)
    count_only_or_objects(count_only, objects, :description)
  end
end
