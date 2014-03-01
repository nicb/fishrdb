#
# $Id: attribute_display.rb 389 2009-04-27 00:48:40Z nicb $
#

module TapeDataParts

  module AttributeDisplay

  protected

    def display_mapper(map, method)
      result = ''
      key = send(method)
      unless key.blank?
        result = map[key]
        if result.blank?
          result = key.downcase
        end
      end
      return result
    end

  public

    def display_reel_material
      map = { 'PLAST' => 'plastica', 'MET'   => 'metallo', 'NONE'  => 'senza bobina', }
      return display_mapper(map, :reel_material)
    end

    def display_tape_material
      map = { 'ACE'   => 'acetato', 'POL'   => 'poliestere', 'PVC'   => 'PVC', }
      return display_mapper(map, :tape_material)
    end

    def display_brand_evidence
      map = { 'B'   => 'sulla scatola', 'N'   => 'sul nastro', 'R'   => 'sulla bobina', }
      return display_mapper(map, :brand_evidence)
    end

  end

end
