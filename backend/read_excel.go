package main

import (
	"fmt"
	"log"
	"github.com/xuri/excelize/v2"
)

func main() {
	f, err := excelize.OpenFile("../docs/District_Masters.xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		if err := f.Close(); err != nil {
			log.Fatal(err)
		}
	}()

	sheets := f.GetSheetList()
	if len(sheets) == 0 {
		log.Fatal("No sheets found")
	}

	rows, err := f.GetRows(sheets[0])
	if err != nil {
		log.Fatal(err)
	}

	for i, row := range rows {
		if i > 10 {
			break
		}
		fmt.Printf("Row %d: %v\n", i, row)
	}
}
