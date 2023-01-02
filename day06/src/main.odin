package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"

main :: proc() {
    //data, ok := os.read_entire_file_from_filename("sample.txt")
    data, ok := os.read_entire_file_from_filename("input.txt")
    if !ok {
        fmt.println("error opening file")
        return
    }
    defer delete(data)

    chars := string(data)
    for i in 14..=len(chars) {
        if all_unique(chars[i-14:i]) {
            fmt.println("Found at char:", i)
            return
        }
    }
}

all_unique :: proc(chars: string) -> bool {
    found := make(map[rune]bool)
    defer delete(found)

    for c in chars {
        if found[c] {
            return false
        }
        found[c] = true
    }
    return true
}

pt1 :: proc() {
    //data, ok := os.read_entire_file_from_filename("sample.txt")
    data, ok := os.read_entire_file_from_filename("input.txt")
    if !ok {
        fmt.println("error opening file")
        return
    }
    defer delete(data)

    chars := string(data)
    for i in 4..=len(chars) {
        if all_unique(chars[i-4:i]) {
            fmt.println("Found at char:", i)
            return
        }
    }
}
