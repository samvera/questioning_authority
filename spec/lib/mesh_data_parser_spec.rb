require 'spec_helper'

describe Authorities::MeshTools::MeshDataParser do

  it "parses a record correctly" do
    data = <<-EOS
*NEWRECORD
A = 45
B = a = b = c = d
B = more than one
EOS
    mesh = Authorities::MeshTools::MeshDataParser.new(StringIO.new(data))
    records = mesh.all_records
    records.length.should == 1
    records[0].should == {'A'=>['45'],'B'=>['a = b = c = d','more than one']}
  end

  it "handles two records" do
    data = <<-EOS
*NEWRECORD
A = 45
B = a = b = c = d

*NEWRECORD
A = another field
print entry = test

EOS
    mesh = Authorities::MeshTools::MeshDataParser.new(StringIO.new(data))
    records = mesh.all_records
    records.length.should == 2
    records[0].should == {'A'=>['45'],'B'=>['a = b = c = d']}
    records[1].should == {'A'=>['another field'], 'print entry'=>['test']}
  end

  it 'ignores bad input' do
    data = <<-EOS
*NEWRECORD
A = 45
B=no space
 space at beginning of line and no =
*NEWRECORD
EOS
    mesh = Authorities::MeshTools::MeshDataParser.new(StringIO.new(data))
    records = mesh.all_records
    records.length.should == 2
    records[0].should == {'A'=>['45']}
    records[1].should == {}
  end

  it 'parses a sample mesh file' do
    mesh = Authorities::MeshTools::MeshDataParser.new(File.new(Rails.root + 'spec/fixtures/mesh.txt'))
    records = mesh.all_records
    records.length.should == 11
    records[0].should == {
      "RECTYPE" => ["D"],
      "MH" => ["Malaria"],
      "AQ" => ["BL CF CI CL CN CO DH DI DT EC EH EM EN EP ET GE HI IM ME MI MO NU PA PC PP PS PX RA RH RI RT SU TH TM UR US VE VI"],
      "PRINT ENTRY" => ["Marsh Fever|T047|NON|EQV|NLM (2006)|050114|abcdef",
                        "Plasmodium Infections|T047|NON|EQV|UNK (19XX)|740330|PLASMODIUM INFECT|abcdefv",
                        "Remittent Fever|T047|NON|EQV|NLM (2006)|050114|abcdef"],
      "ENTRY" => ["Infections, Plasmodium|T047|NON|EQV|NLM (1992)|911126|INFECT PLASMODIUM|abcdefv",
                  "Paludism|T047|NON|EQV|NLM (2005)|040220|abcdef",
                  "Fever, Marsh",
                  "Fever, Remittent",
                  "Infection, Plasmodium",
                  "Plasmodium Infection"],
      "MN" => ["C03.752.530", "C23.996.660"],
      "FX" => ["Antimalarials"],
      "MH_TH" => ["NLM (1986)", "ORD (2010)"],
      "ST" => ["T047"],
      "AN" => ["GEN or unspecified; specify Plasmodium species IM if possible but note P. falciparum malaria = MALARIA, FALCIPARUM; P. vivax malaria = MALARIA, VIVAX; tertian malaria = MALARIA, VIVAX, quartan malaria: coord IM with PLASMODIUM MALARIAE (IM); malariotherapy = HYPERTHERMIA, INDUCED: do not confuse with MALARIA /ther; /drug ther: consider also ANTIMALARIALS"],
      "MS" => ["A protozoan disease caused in humans by four species of the PLASMODIUM genus: PLASMODIUM FALCIPARUM; PLASMODIUM VIVAX; PLASMODIUM OVALE; and PLASMODIUM MALARIAE; and transmitted by the bite of an infected female mosquito of the genus ANOPHELES. Malaria is endemic in parts of Asia, Africa, Central and South America, Oceania, and certain Caribbean islands. It is characterized by extreme exhaustion associated with paroxysms of high FEVER; SWEATING; shaking CHILLS; and ANEMIA. Malaria in ANIMALS is caused by other species of plasmodia."],
      "OL" => ["use MALARIA to search MALARIA CONTROL 1966"],
      "PM" => ["MALARIA CONTROL was heading 1963-66"],
      "HN" => ["MALARIA CONTROL was heading 1963-66"],
      "MED" => ["*1141", "1541"],
      "M90" => ["*2010", "2428"],
      "M85" => ["*2929", "3509"],
      "M80" => ["*2008", "2567"],
      "M75" => ["*1414", "1928"],
      "M66" => ["*2561", "3568"],
      "M94" => ["*1272", "1646"],
      "CATSH" => ["CAT LIST"],
      "MR" => ["20120703"],
      "DA" => ["19990101"],
      "DC" => ["1"],
      "UI" => ["D008288"]
    }
    records[1].should == {
      "RECTYPE" => ["D"],
      "MH" => ["Calcimycin"],
      "AQ" => ["AA AD AE AG AI AN BI BL CF CH CL CS CT DU EC HI IM IP ME PD PK PO RE SD ST TO TU UR"],
      "ENTRY" => ["A-23187|T109|T195|LAB|NRW|NLM (1991)|900308|abbcdef",
        "A23187|T109|T195|LAB|NRW|UNK (19XX)|741111|abbcdef",
        "Antibiotic A23187|T109|T195|NON|NRW|NLM (1991)|900308|abbcdef",
        "A 23187",
        "A23187, Antibiotic"],
      "MN" => ["D03.438.221.173"],
      "PA" => ["Anti-Bacterial Agents", "Calcium Ionophores"],
      "MH_TH" => ["NLM (1975)"],
      "ST" => ["T109", "T195"],
      "N1" => ["4-Benzoxazolecarboxylic acid, 5-(methylamino)-2-((3,9,11-trimethyl-8-(1-methyl-2-oxo-2-(1H-pyrrol-2-yl)ethyl)-1,7-dioxaspiro(5.5)undec-2-yl)methyl)-, (6S-(6alpha(2S*,3S*),8beta(R*),9beta,11alpha))-"],
      "RN" => ["52665-69-7"],
      "PI" => ["Antibiotics (1973-1974)", "Carboxylic Acids (1973-1974)"],
      "MS" => ["An ionophorous, polyether antibiotic from Streptomyces chartreusensis. It binds and transports CALCIUM and other divalent cations across membranes and uncouples oxidative phosphorylation while inhibiting ATPase of rat liver mitochondria. The substance is used mostly as a biochemical tool to study the role of divalent cations in various biological systems."],
      "OL" => ["use CALCIMYCIN to search A 23187 1975-90"],
      "PM" => ["91; was A 23187 1975-90 (see under ANTIBIOTICS 1975-83)"],
      "HN" => ["91(75); was A 23187 1975-90 (see under ANTIBIOTICS 1975-83)"],
      "MED" => ["*62", "847"],
      "M90" => ["*299", "2405"],
      "M85" => ["*454", "2878"],
      "M80" => ["*316", "1601"],
      "M75" => ["*300", "823"],
      "M66" => ["*1", "3"],
      "M94" => ["*153", "1606"],
      "MR" => ["20110624"],
      "DA" => ["19741119"],
      "DC" => ["1"],
      "DX" => ["19840101"],
      "UI" => ["D000001"]
    }
  end
end

