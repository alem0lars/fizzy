Fizzy::Vars::Filter.define(:lpass, description: "" "
LastPass filter allows to retrieve informations stored in a lastpass account
As arguments you can pass:
- #0: A unique name or identifier of the element to be retrieved
- #1 [optional]: What information should be retrieved from the element
                 (defaults to the element's password)
" "") do |args|
  args = args.split_by_separator
  name = args[0].shell_escape
  what = args[1] || :password
  what = "--#{what}" unless what.to_s.start_with?("--")
  `lpass show --color=never #{what} #{name}`.strip
end
