require 'sinatra'
require 'open-uri'
require 'json'
require 'crack'

class KYC < Sinatra::Base

@@repower_count = 2310000001010101034
@@moneysend_count = 2310000001010101122


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
    amount = params[:amount]
    card_number = params[:card_number]
    @@repower_count = @@repower_count + 1
    # CardNumber=5184680430000006
    xml_string = "<RepowerRequest>
         <TransactionReference>#{@@repower_count}</TransactionReference>
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
    p response.body
    puts ' '
    p @@repower_count
    { status: 200, value: amount, card_number: card_number}.to_json
  end

  get '/moneysend/transfer/:funding_card/:receiver_card/:value' do
    @@moneysend_count = @@moneysend_count +1 
    funding_card = params[:funding_card]
    receiver_card = params[:receiver_card]
    amount = params[:value]
    # FundingCard.AccountNumber=5184680430000014
    # ReceiverCard.AccountNumber=5184680430000006
    xml_string = "<TransferRequest>
     <LocalDate>0612</LocalDate>
     <LocalTime>161222</LocalTime>
     <TransactionReference>#{@@moneysend_count}</TransactionReference>
     <SenderName>John Doe</SenderName>
     <SenderAddress>
        <Line1>123 Main Street</Line1>

        <City>Arlington</City>
        <CountrySubdivision>VA</CountrySubdivision>
        <PostalCode>22207</PostalCode>
        <Country>USA</Country>
     </SenderAddress>
     <FundingCard>
        <AccountNumber>#{funding_card}</AccountNumber>
        <ExpiryMonth>11</ExpiryMonth>
        <ExpiryYear>2016</ExpiryYear>
     </FundingCard>

     <FundingMasterCardAssignedId>123456</FundingMasterCardAssignedId>
     <FundingAmount>
        <Value>16000</Value>
        <Currency>840</Currency>
     </FundingAmount>
     <ReceiverName>Jose Lopez</ReceiverName>
     <ReceiverAddress>
        <Line1>Pueblo Street</Line1>
        <Line2>PO BOX 12</Line2>
        <City>El PASO</City>
        <CountrySubdivision>TX</CountrySubdivision>
        <PostalCode>79906</PostalCode>
        <Country>USA</Country>
     </ReceiverAddress>
     <ReceiverPhone>1800639426</ReceiverPhone>
     <ReceivingCard>
        <AccountNumber>#{receiver_card}</AccountNumber>
     </ReceivingCard>
     <ReceivingAmount>
        <Value>#{amount}</Value>
        <Currency>484</Currency>
     </ReceivingAmount>
     <Channel>W</Channel>
     <UCAFSupport>true</UCAFSupport>
     <ICA>009674</ICA>
     <ProcessorId>9000000442</ProcessorId>
     <RoutingAndTransitNumber>990442082</RoutingAndTransitNumber>
     <CardAcceptor>
        <Name>My Local Bank</Name>
        <City>Saint Louis</City>
        <State>MO</State>
        <PostalCode>63101</PostalCode>
        <Country>USA</Country>
     </CardAcceptor>
    <TransactionDesc>P2P</TransactionDesc>
    <MerchantId>123456</MerchantId>
  </TransferRequest>
  "


    uri = URI.parse("http://dmartin.org:8021/moneysend/v2/transfer")
    request = Net::HTTP::Post.new uri.path
    request.body = xml_string
    request.content_type = 'application/xml'
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
    response.body
    status 200
    { status: 200, funding_card: funding_card, receiver_card: receiver_card, value: amount}.to_json
  end





end