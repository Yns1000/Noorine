import UIKit

struct GlyphBoundingBox {
    let letter: String
    let formType: String
    let minX: CGFloat
    let maxX: CGFloat
    let minY: CGFloat
    let maxY: CGFloat

    var width: CGFloat { maxX - minX }
    var height: CGFloat { maxY - minY }
    var centerX: CGFloat { (minX + maxX) / 2 }
    var centerY: CGFloat { (minY + maxY) / 2 }

    var description: String {
        String(format: "[\(formType)] \"\(letter)\" -> minX=%.3f maxX=%.3f minY=%.3f maxY=%.3f (w=%.3f h=%.3f)",
               minX, maxX, minY, maxY, width, height)
    }
}


enum GlyphCalibrator {

    static let canvasSize = CGSize(width: 250, height: 250)
    static let fontSize: CGFloat = 162.5
    static var font: UIFont { UIFont.systemFont(ofSize: fontSize, weight: .regular) }

    struct LetterEntry {
        let name: String
        let id: Int
        let forms: [(formType: String, glyph: String)]
    }

    static let allLetters: [LetterEntry] = [
        LetterEntry(name: "Alif", id: 1, forms: [
            ("isolated", "\u{0627}"),
            ("final",    "\u{0640}\u{0627}")
        ]),
        LetterEntry(name: "Ba", id: 2, forms: [
            ("isolated", "\u{0628}"),
            ("initial",  "\u{0628}\u{0640}"),
            ("medial",   "\u{0640}\u{0628}\u{0640}"),
            ("final",    "\u{0640}\u{0628}")
        ]),
        LetterEntry(name: "Ta", id: 3, forms: [
            ("isolated", "\u{062A}"),
            ("initial",  "\u{062A}\u{0640}"),
            ("medial",   "\u{0640}\u{062A}\u{0640}"),
            ("final",    "\u{0640}\u{062A}")
        ]),
        LetterEntry(name: "Tha", id: 4, forms: [
            ("isolated", "\u{062B}"),
            ("initial",  "\u{062B}\u{0640}"),
            ("medial",   "\u{0640}\u{062B}\u{0640}"),
            ("final",    "\u{0640}\u{062B}")
        ]),
        LetterEntry(name: "Jim", id: 5, forms: [
            ("isolated", "\u{062C}"),
            ("initial",  "\u{062C}\u{0640}"),
            ("medial",   "\u{0640}\u{062C}\u{0640}"),
            ("final",    "\u{0640}\u{062C}")
        ]),
        LetterEntry(name: "Ha", id: 6, forms: [
            ("isolated", "\u{062D}"),
            ("initial",  "\u{062D}\u{0640}"),
            ("medial",   "\u{0640}\u{062D}\u{0640}"),
            ("final",    "\u{0640}\u{062D}")
        ]),
        LetterEntry(name: "Kha", id: 7, forms: [
            ("isolated", "\u{062E}"),
            ("initial",  "\u{062E}\u{0640}"),
            ("medial",   "\u{0640}\u{062E}\u{0640}"),
            ("final",    "\u{0640}\u{062E}")
        ]),
        LetterEntry(name: "Dal", id: 8, forms: [
            ("isolated", "\u{062F}"),
            ("final",    "\u{0640}\u{062F}")
        ]),
        LetterEntry(name: "Dhal", id: 9, forms: [
            ("isolated", "\u{0630}"),
            ("final",    "\u{0640}\u{0630}")
        ]),
        LetterEntry(name: "Ra", id: 10, forms: [
            ("isolated", "\u{0631}"),
            ("final",    "\u{0640}\u{0631}")
        ]),
        LetterEntry(name: "Zay", id: 11, forms: [
            ("isolated", "\u{0632}"),
            ("final",    "\u{0640}\u{0632}")
        ]),
        LetterEntry(name: "Sin", id: 12, forms: [
            ("isolated", "\u{0633}"),
            ("initial",  "\u{0633}\u{0640}"),
            ("medial",   "\u{0640}\u{0633}\u{0640}"),
            ("final",    "\u{0640}\u{0633}")
        ]),
        LetterEntry(name: "Shin", id: 13, forms: [
            ("isolated", "\u{0634}"),
            ("initial",  "\u{0634}\u{0640}"),
            ("medial",   "\u{0640}\u{0634}\u{0640}"),
            ("final",    "\u{0640}\u{0634}")
        ]),
        LetterEntry(name: "Sad", id: 14, forms: [
            ("isolated", "\u{0635}"),
            ("initial",  "\u{0635}\u{0640}"),
            ("medial",   "\u{0640}\u{0635}\u{0640}"),
            ("final",    "\u{0640}\u{0635}")
        ]),
        LetterEntry(name: "Dad", id: 15, forms: [
            ("isolated", "\u{0636}"),
            ("initial",  "\u{0636}\u{0640}"),
            ("medial",   "\u{0640}\u{0636}\u{0640}"),
            ("final",    "\u{0640}\u{0636}")
        ]),
        LetterEntry(name: "Ta_emphatic", id: 16, forms: [
            ("isolated", "\u{0637}"),
            ("initial",  "\u{0637}\u{0640}"),
            ("medial",   "\u{0640}\u{0637}\u{0640}"),
            ("final",    "\u{0640}\u{0637}")
        ]),
        LetterEntry(name: "Za_emphatic", id: 17, forms: [
            ("isolated", "\u{0638}"),
            ("initial",  "\u{0638}\u{0640}"),
            ("medial",   "\u{0640}\u{0638}\u{0640}"),
            ("final",    "\u{0640}\u{0638}")
        ]),
        LetterEntry(name: "Ayn", id: 18, forms: [
            ("isolated", "\u{0639}"),
            ("initial",  "\u{0639}\u{0640}"),
            ("medial",   "\u{0640}\u{0639}\u{0640}"),
            ("final",    "\u{0640}\u{0639}")
        ]),
        LetterEntry(name: "Ghayn", id: 19, forms: [
            ("isolated", "\u{063A}"),
            ("initial",  "\u{063A}\u{0640}"),
            ("medial",   "\u{0640}\u{063A}\u{0640}"),
            ("final",    "\u{0640}\u{063A}")
        ]),
        LetterEntry(name: "Fa", id: 20, forms: [
            ("isolated", "\u{0641}"),
            ("initial",  "\u{0641}\u{0640}"),
            ("medial",   "\u{0640}\u{0641}\u{0640}"),
            ("final",    "\u{0640}\u{0641}")
        ]),
        LetterEntry(name: "Qaf", id: 21, forms: [
            ("isolated", "\u{0642}"),
            ("initial",  "\u{0642}\u{0640}"),
            ("medial",   "\u{0640}\u{0642}\u{0640}"),
            ("final",    "\u{0640}\u{0642}")
        ]),
        LetterEntry(name: "Kaf", id: 22, forms: [
            ("isolated", "\u{0643}"),
            ("initial",  "\u{0643}\u{0640}"),
            ("medial",   "\u{0640}\u{0643}\u{0640}"),
            ("final",    "\u{0640}\u{0643}")
        ]),
        LetterEntry(name: "Lam", id: 23, forms: [
            ("isolated", "\u{0644}"),
            ("initial",  "\u{0644}\u{0640}"),
            ("medial",   "\u{0640}\u{0644}\u{0640}"),
            ("final",    "\u{0640}\u{0644}")
        ]),
        LetterEntry(name: "Mim", id: 24, forms: [
            ("isolated", "\u{0645}"),
            ("initial",  "\u{0645}\u{0640}"),
            ("medial",   "\u{0640}\u{0645}\u{0640}"),
            ("final",    "\u{0640}\u{0645}")
        ]),
        LetterEntry(name: "Nun", id: 25, forms: [
            ("isolated", "\u{0646}"),
            ("initial",  "\u{0646}\u{0640}"),
            ("medial",   "\u{0640}\u{0646}\u{0640}"),
            ("final",    "\u{0640}\u{0646}")
        ]),
        LetterEntry(name: "Ha_light", id: 26, forms: [
            ("isolated", "\u{0647}"),
            ("initial",  "\u{0647}\u{0640}"),
            ("medial",   "\u{0640}\u{0647}\u{0640}"),
            ("final",    "\u{0640}\u{0647}")
        ]),
        LetterEntry(name: "Waw", id: 27, forms: [
            ("isolated", "\u{0648}"),
            ("final",    "\u{0640}\u{0648}")
        ]),
        LetterEntry(name: "Ya", id: 28, forms: [
            ("isolated", "\u{064A}"),
            ("initial",  "\u{064A}\u{0640}"),
            ("medial",   "\u{0640}\u{064A}\u{0640}"),
            ("final",    "\u{0640}\u{064A}")
        ]),
        LetterEntry(name: "TaMarbuta", id: 29, forms: [
            ("isolated", "\u{0629}"),
            ("final",    "\u{0640}\u{0629}")
        ]),
        LetterEntry(name: "Hamza", id: 30, forms: [
            ("isolated", "\u{0621}")
        ])
    ]

    private static func renderLetter(_ letter: String) -> UIImage {
        let size = canvasSize
        let currentFont = font

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font: currentFont,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]

            let textSize = letter.size(withAttributes: attrs)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            letter.draw(in: rect, withAttributes: attrs)
        }
    }

    private static func scanBoundingBox(image: UIImage) -> (minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat)? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow

        var pixelData = [UInt8](repeating: 0, count: totalBytes)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: &pixelData,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let threshold: UInt8 = 10

        var foundMinX = width
        var foundMaxX = 0
        var foundMinY = height
        var foundMaxY = 0
        var foundAny = false

        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                let r = pixelData[offset]
                let g = pixelData[offset + 1]
                let b = pixelData[offset + 2]

                if r > threshold || g > threshold || b > threshold {
                    foundAny = true
                    if x < foundMinX { foundMinX = x }
                    if x > foundMaxX { foundMaxX = x }
                    if y < foundMinY { foundMinY = y }
                    if y > foundMaxY { foundMaxY = y }
                }
            }
        }

        guard foundAny else { return nil }

        let normalizedMinX = CGFloat(foundMinX) / CGFloat(width)
        let normalizedMaxX = CGFloat(foundMaxX) / CGFloat(width)
        let normalizedMinY = CGFloat(foundMinY) / CGFloat(height)
        let normalizedMaxY = CGFloat(foundMaxY) / CGFloat(height)

        return (normalizedMinX, normalizedMaxX, normalizedMinY, normalizedMaxY)
    }

    static func calibrate(letter: String, formType: String) -> GlyphBoundingBox? {
        let image = renderLetter(letter)
        guard let box = scanBoundingBox(image: image) else {
            print("[GlyphCalibrator] WARNING: No pixels found for \"\(letter)\" [\(formType)]")
            return nil
        }
        return GlyphBoundingBox(
            letter: letter,
            formType: formType,
            minX: box.minX,
            maxX: box.maxX,
            minY: box.minY,
            maxY: box.maxY
        )
    }

    @discardableResult
    static func calibrateAll() -> [GlyphBoundingBox] {
        var results: [GlyphBoundingBox] = []
        var output = ""

        func log(_ s: String) {
            print(s)
            output += s + "\n"
        }

        log("=== GlyphCalibrator: Starting calibration ===")
        log("Canvas: \(Int(canvasSize.width))x\(Int(canvasSize.height)), Font size: \(fontSize)pt")
        log("Font: \(font.fontName)")
        log("")

        for entry in allLetters {
            log("--- \(entry.name) (id: \(entry.id)) ---")

            for (formType, glyph) in entry.forms {
                if let box = calibrate(letter: glyph, formType: formType) {
                    results.append(box)
                    log("  \(box.description)")
                }
            }
        }


        for entry in allLetters {
            for (formType, glyph) in entry.forms {
                if let box = results.first(where: { $0.letter == glyph && $0.formType == formType }) {
                    let key = "\(entry.id)_\(formType)"
                    log(String(format: "    \"%@\": (minX: %.4f, maxX: %.4f, minY: %.4f, maxY: %.4f),",
                                 key, box.minX, box.maxX, box.minY, box.maxY))
                }
            }
        }

        log("]")

        if let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = docsDir.appendingPathComponent("glyph_calibration.txt")
            try? output.write(to: fileURL, atomically: true, encoding: .utf8)
            print("[GlyphCalibrator] Results written to: \(fileURL.path)")
        }

        return results
    }
}
