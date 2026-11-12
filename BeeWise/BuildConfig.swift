import Foundation

/// Saklar poin development vs production.
///
/// - `isProd = true`  → hari sempurna nambah 1 poin (rilis asli)
/// - `isProd = false` → hari sempurna nambah 100 poin (testing biar cepat naik level)
///
/// Cara pakai: ubah isprod false/true
enum BuildConfig {
    static let isProd = true

    static var perfectDayPoints: Int {
        isProd ? 1 : 100
    }
}
