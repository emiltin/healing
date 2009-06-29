#deep nesting, showing how clouds can be nested to arbitrary depth.
#note that an instances can contain subclouds or subinstances.

cloud :music do
  uuid 'op2nm1jhwe2x'
  key '/Users/emiltin/.ec2/testpair'
  dir '/music'
  cloud :rhytmic do
    uuid  'vmcfncnagagnc344'
    dir '/music/rhytmic'
    cloud :jazz do
      dir '/music/rhytmic/jazz'
      instance :bebop do
        uuid  '0vhjj348isjsj3fb'
        dir '/music/rhytmic/jazz/bebop'
      end
      instance :slow do
        uuid  '7877vjujxhhfd2h'
        dir '/music/rhytmic/jazz/slow'
      end
    end
  end
end

