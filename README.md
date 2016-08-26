# Mitake

Taiwan SMS Provider Mitake API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mitake'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mitake

## Usage

Initialize mitake api:
    
    mitake = Mitake::API.new(username: YOUR_USERNAME, password: YOUR_PASSWORD)

Get Account Balance:
    
    mitake.get_balance

Send Message:

```ruby
mitake.send_sms(numbers: DEST_MOBILE, message: YOUR_MESSAGE)
mitake.send_sms(numbers: [DEST_MOBILE1, DEST_MOBILE2, DEST_MOBILE3], message: YOUR_MESSAGE) 
#[{"msgid"=>"0939137671", "statuscode"=>"1"}, {"msgid"=>"0939138467", "statuscode"=>"1"}, {"AccountPoint"=>"96"}]
# or
#{"statuscode"=>"e", "Error"=>"帳號、密碼錯誤"}

mitake.send_long_sms(number: DEST_MOBILE, message: YOUR_MESSAGE)
#for message more then 70 characters
```

Get Message Status:

```ruby
mitake.get_message(msgid: MESSAGE_ID)
mitake.get_message(msgid: MESSAGE_ID1, MESSAGE_ID2, MESSAGE_ID3)
#{"msgid"=>"0939137671", "statuscode"=>"4", "statustime"=>"20160808153248"}
```

StatusFlag shown in the table below:

| StatusFlag | Description                  |
-------------|------------------------------|
0            | Reservation                  |
1            | Has been served              |
2            | Has been served              |
3            | Has been served              |
4            | Has been served              |
5            | Content with errors          |
6            | Phone number with errors     |
7            | Has been disabled            |
8            | Timeout                      |
9            | Reservation has been canceled|

statuscode shown in the table below:

| statuscode | Description                                                         |
-------------|---------------------------------------------------------------------|
*            | System error, please contact Mitake.                                |
a            | SMS sending is temporarily out of service. Please try again later.  |
b            | SMS sending is temporarily out of service. Please try again later.  |
c            | Please enter your account.                                          |
d            | Please enter your password.                                         |
e            | Account and password error.                                         |
f            | Account has expired.                                                |
h            | Account has disabled.                                               |
k            | Invalid connection address.                                         |
m            | You must change your password.                                      |
n            | Password has expired.                                               |
p            | Permission denied.                                                  |
r            | System out of service, please try again later.                      |
s            | Accounting treatment failure.                                       |
t            | SMS has expired.                                                    |
u            | SMS content can not be blank.                                       |
v            | Invalid phone number.                                               |
0            | Reservation                                                         |
1            | Has been served                                                     |
2            | Has been served                                                     |
3            | Has been served                                                     |
4            | Has been served                                                     |
5            | Content with errors                                                 |
6            | Phone number with errors                                            |
7            | Has been disabled                                                   |
8            | Timeout                                                             |
9            | Reservation has been canceled                                       |

statusstr shown in the table below:

| statusstr | StatusFlag | Description                                                            |
------------|------------|------------------------------------------------------------------------|
DELIVRD     | 4          | Has been served                                                        |
EXPIRED     | 8          | Timeout                                                                |
DELETED     | 9          | Reservation has been canceled                                          |
UNDELIV     | 6,7        | Undeliverable (Phone number with errors / SMS has been disabled)       |
ACCEPTD     | 0, 1, 2, 3 | SMS Processing (0 = appointment, 1,2,3 = the carriers has been served) |
UNKNOWN     |            | Invalid SMS status, system error                                       |
REJECTD     |            |                                                                        |
SYNTAXE     | 5          | SMS content error                                                      |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/j094097/mitake. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

