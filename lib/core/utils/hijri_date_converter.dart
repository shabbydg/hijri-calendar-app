/**
 * Hijri Date Converter - Ported from proven JavaScript algorithms
 * 
 * This file contains the core date conversion functions between Gregorian and Hijri calendars
 * using the tested and verified algorithms from the Mumineen Calendar project.
 * 
 * Source: https://github.com/mygulamali/mumineen_calendar_js
 */

/**
 * Checks if a date is in the Julian calendar (before 1582)
 */
bool isJulian(DateTime date) {
  if (date.year < 1582) {
    return true;
  } else if (date.year == 1582) {
    if (date.month < 10) {
      return true;
    } else if (date.month == 10) {
      if (date.day < 5) {
        return true;
      }
    }
  }
  return false;
}

/**
 * Converts a Gregorian date to Astronomical Julian Day (AJD)
 */
double gregorianToAJD(DateTime date) {
  double a, b;
  int year = date.year;
  int month = date.month;
  double day = date.day +
      date.hour / 24 +
      date.minute / 1440 +
      date.second / 86400 +
      date.millisecond / 86400000;

  if (month < 3) {
    year--;
    month += 12;
  }

  if (isJulian(date)) {
    b = 0;
  } else {
    a = (year / 100).floor().toDouble();
    b = 2 - a + (a / 4).floor();
  }

  return (365.25 * (year + 4716)).floor() +
      (30.6001 * (month + 1)).floor() +
      day +
      b -
      1524.5;
}

/**
 * Converts Astronomical Julian Day (AJD) to Gregorian date
 */
DateTime ajdToGregorian(double ajd) {
  double a, b, c, d, e, f, z, alpha;
  int year, month;
  double day, hrs, min, sec, msc;

  z = (ajd + 0.5).floor().toDouble();
  f = (ajd + 0.5 - z);

  if (z < 2299161) {
    a = z;
  } else {
    alpha = ((z - 1867216.25) / 36524.25).floor().toDouble();
    a = z + 1 + alpha - (0.25 * alpha).floor();
  }

  b = a + 1524;
  c = ((b - 122.1) / 365.25).floor().toDouble();
  d = (365.25 * c).floor().toDouble();
  e = ((b - d) / 30.6001).floor().toDouble();

  day = b - d - (30.6001 * e).floor() + f;
  hrs = (day.floor() - day) * 24;
  min = (hrs.floor() - hrs) * 60;
  sec = (min.floor() - min) * 60;
  msc = (sec.floor() - sec) * 1000;

  month = (e < 14) ? (e - 2).toInt() : (e - 14).toInt();
  year = (month < 2) ? (c - 4715).toInt() : (c - 4716).toInt();

  // Adjust month to 1-based indexing for DateTime constructor
  month = month + 1;

  return DateTime(
    year,
    month,
    day.floor().toInt(),
    hrs.floor().toInt(),
    min.floor().toInt(),
    sec.floor().toInt(),
    msc.floor().toInt(),
  );
}
