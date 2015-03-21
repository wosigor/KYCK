require 'sinatra'
require 'open-uri'
require 'json'
require 'crack'

class KYC < Sinatra::Base


  ############    
  # LOCATIONS
  ############
  #
  # Get location data for the given country and city
  #
  get '/locations/:country/:city' do
    # Country=USA
    # PostalCode=63366
    url = "http://dmartin.org:8021/atms/v1/atm?Format=XML&PageOffset=0&PageLength=10&City=#{params[:city]}&Country=#{params[:country]}&InternationalMaestroAccepted=1"
    result = open(url)

    myXML  = Crack::XML.parse(result)
    myJSON = myXML.to_json
  end

  ############    
  # RePower
  ############
  #
  # Forward post request for re-powering of the account balance
  # for a given account ID
  #
  get '/repower/:amount/:card_number' do
    # CardNumber=5184680430000006
    xml_string = "<RepowerRequest>
   <TransactionReference>2310000001010101014</TransactionReference>
    <CardNumber>#{params[:card_number]}</CardNumber>
    <TransactionAmount>
        <Value>#{params[:amount]}</Value>
        <Currency>840</Currency>
    </TransactionAmount>
    <LocalDate>1230</LocalDate>
    <LocalTime>092435</LocalTime>
    <!--Card Acceptor Information-->
    <Channel>W</Channel>
    <ICA>009674</ICA>
    <ProcessorId>9000000442</ProcessorId>
    <RoutingAndTransitNumber>990442082</RoutingAndTransitNumber>
    <MerchantType>6532</MerchantType>
    <CardAcceptor>
        <Name>Prepaid Card</Name>
        <City>St Charles</City>
        <State>MO</State>
        <PostalCode>63301</PostalCode>
        <Country>USA</Country>
    </CardAcceptor> 
</RepowerRequest>"
    card_number = params['card_number']
    value = params['value']

    uri = URI.parse("http://dmartin.org:8021/repower/v1/repower")
    request = Net::HTTP::Post.new uri.path
    request.body = xml_string
    request.content_type = 'application/xml'
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
    response.body
    status 200
    "Added amount:#{params[:amount]} to card number: #{params[:card_number]}"
  end



end