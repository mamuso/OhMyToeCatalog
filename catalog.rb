require "rubygems"
require "rational"

require 'pdfkit'

PATH = File.expand_path(File.join(File.dirname(__FILE__), "")) + "/"

MODELS = Dir.glob(File.join("**", "mod", "*.JPG"))
PAGES = [
    [["grid", 8],["grid", 8]],
    [["grid", 6],["grid", 6]],
    [["grid", 6],["grid", 6]],
    [["trio", 3],["trio", 3]],
    [["grid", 6],["grid", 6]],
    [["grid", 6],["grid", 6]],
    [["grid", 6],["grid", 6]]
  ]
    
    # [["grid", 8],["grid", 8]],
    # [["grid", 6],["grid", 5]],
    # [["mono", 1],["duo", 2]],
    # [["grid", 8],["grid", 8]],
    # [["grid", 6],["grid", 6]],
    # [["grid", 6],["grid", 6]],
    # [["grid", 6],["trio", 3]]
  
  # mono
  # duo
  # trio
  # grid
  
pages_html = []
page = ""
offset = 0
v = 0 # contador para hacer el 01100110 de la imposición
 
puts "#{MODELS.size} fotos"
puts "#{PAGES.size} páginas"

page_open = '<div class="page">
			<table border="0" cellspacing="5" cellpadding="5" width="98%" align="center">
				<tr>
					<td width="50%">
						<table border="0" cellspacing="5" cellpadding="5" aligh="center" class="models">
'
page_join = '	</table>
</td>

<td width="50%">
	<table border="0" cellspacing="5" cellpadding="5" aligh="center" class="models">
'
page_close = '						</table>
					</td>
					
				</tr>
			</table>
		</div>
'


html = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

	<title></title>
	<link rel="stylesheet" href="' +PATH+ 'css/catalog.css" type="text/css" media="screen" charset="utf-8"/>
	
</head>

<body>'

# ------------------------------------------
# Creating the pagebases
# ------------------------------------------
0.upto(PAGES.size-1) {|i|
  0.upto(PAGES[i].size-1) {|p|
    MODELS.slice(offset, PAGES[i][p][1]).each_with_index do |mod, u|
      cellheightbase = 800
      if PAGES[i][p][0] == "grid"
        if PAGES[i][p][0]%2 == 0
          cellheight = cellheightbase/(PAGES[i][p][1]/2)
        else
          cellheight = cellheightbase/((PAGES[i][p][1]+1)/2)
        end
      else 
        cellheight = cellheightbase/PAGES[i][p][1]
      end
      # mono
        page << '<tr class="row '+PAGES[i][p][0]+'" height="'+cellheight.to_s+'">' if (PAGES[i][p][0] == "mono")
      # duo
        page << '<tr class="row '+PAGES[i][p][0]+'" height="'+cellheight.to_s+'">' if (PAGES[i][p][0] == "duo")
      # duo
        page << '<tr class="row '+PAGES[i][p][0]+'" height="'+cellheight.to_s+'">' if (PAGES[i][p][0] == "trio")
      # grid
        page << '<tr class="row '+PAGES[i][p][0]+'" height="'+cellheight.to_s+'">' if (u+1)%2!=0 && (PAGES[i][p][0] == "grid")
      page << '<td'+(((u+1)%2!=0 && u+1 >= PAGES[i][p][1]) ? " colspan='2'" : "") +' height="'+cellheight.to_s+'"><div class="model"><img src="' +PATH+mod + '"/><strong>'+File.basename(mod, ".JPG").gsub("_", " ")+'</strong></div></td>'
      page <<'</tr>' if (((u+1)%2==0 || u+1 >= PAGES[i][p][1]) && PAGES[i][p][0] == "grid") || (PAGES[i][p][0] == "duo") || (PAGES[i][p][0] == "mono") || (PAGES[i][p][0] == "trio")
    end unless MODELS.slice(offset, PAGES[i][p][1]).nil?
    offset += PAGES[i][p][1]
    pages_html << page
    page = ""
  }
}

# ------------------------------------------
# Joining
# ------------------------------------------
0.upto(PAGES.size-1) {|i|
  html << page_open
  0.upto(PAGES[i].size-1) {|p|
    (p+1)%2 == 0 ? (v == 0 ? v = 1 : v = 0) : ""            # impuesto
    h = v == 0 ? pages_html.shift : pages_html.pop          # impuesto
    html << h                                               # impuesto
    # html << pages_html[2*i+p]                             # sin imposición
    html << page_join if (p+1)%2 != 0
  }
  html << page_close
}

html << '</body></html>'

# ------------------------------------------
# Creating PDF
# ------------------------------------------
kit = PDFKit.new(html, {
  :page_size      => 'A3',
  :orientation    => 'Landscape',
  :margin_top     => '0in',
  :margin_right   => '0in',
  :margin_bottom  => '0in',
  :margin_left    => '0in'
})
file = kit.to_file('pdf.pdf')
