import os
import time
import net.http
import x.json2 as json

pub struct Item
{
        pub mut:
                name                    string
                id                              int
                img_url         string
}

pub struct Scrape
{
        pub mut:
                items_url       string = "https://yoworlddb.com/items/page/"
                data                    string
                items                   []Item

                //loop settings
                c_page          int
}

fn main()
{
        mut s := start_session()
        s.fetch_items()
        os.write_file("items.txt", s.data) or { return }
        print("\x1b[96mSuccessfully Scraped All Yoworld Items\x1b[0m")
}

pub fn start_session() Scrape
{
        mut s := Scrape{}
        return s
}

pub fn (mut s Scrape) fetch_items()
{
        for i in 0..4137
        {
                s.c_page = i
                item_page := http.get_text("${s.items_url}${i}")
                go s.scrape_page(item_page)
        }
}

pub fn (mut s Scrape) scrape_page(content string)
{
        page_lines := content.split("\n")

        mut c := 0
        mut item_name := ""
        mut item_id := 0
        mut item_image := ""
        mut item_price := 0

        mut item_count := 0
        for line in page_lines
        {
                if line.contains("<a class=\"item-image\"")
                {
                        item_id = line.split("data")[1].replace("=\"", "").replace("\"></a>", "").split("/")[3].replace(".gif", "").replace("_60_60", "").int()
                        item_image = "https://yw-web.yoworld.com/cdn/items/" + line.trim_space().split("data=\"")[1].replace("\"></a>", "")
                        item_name = page_lines[c+2].replace("</a>", "").trim_space().replace("~ ", "")
                }

                if item_name != "" && item_id > 0 && item_image != "" {
                        mut item := Item{name: item_name, id: item_id, img_url: item_image}
                        s.items << item
                        s.data += "('${item_name}','${item_id}','${item_image}')\n"
                        println("Items: ${s.items.len} | Page: ${s.c_page} |  Name: ${item_name} | ID: ${item_id} | Price: ${item_image}".replace("\n", ""))
                        item_name = ""
                        item_id = 0
                        item_image = ""
                        item_count++
                }
                c++
        }
}
