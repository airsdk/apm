/*
 * Copyright 2009-2010 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.as3commons.lang {

	/**
	 * @author James Ghandour
	 */
	public final class DateUtils {

		public static const MONTHS_PER_YEAR:int=12;
		public static const DAYS_PER_WEEK:int=7;
		public static const HOURS_PER_DAY:int=24;
		public static const MINUTES_PER_HOUR:int=60;
		public static const SECONDS_PER_MINUTE:int=60;

		public static const MILLIS_PER_SECOND:int=1000;
		public static const MILLIS_PER_MINUTE:int=SECONDS_PER_MINUTE * MILLIS_PER_SECOND;
		public static const MILLIS_PER_HOUR:int=MINUTES_PER_HOUR * MILLIS_PER_MINUTE;
		public static const MILLIS_PER_DAY:int=HOURS_PER_DAY * MILLIS_PER_HOUR;


		private static const NOT_NULL_ASSERTION_MESSAGE:String="The dates must not be null.";
		private static const GMT_TIMEZONE_STRING:String="GMT";

		/*
		 *  Comparison Functions
		 */
		public static function isSameDay(date1:Date, date2:Date):Boolean {
			Assert.notNull(date1, NOT_NULL_ASSERTION_MESSAGE);
			Assert.notNull(date2, NOT_NULL_ASSERTION_MESSAGE);

			var result:Boolean=false;
			if (date1.getFullYear() == date2.getFullYear() && date1.getMonth() == date2.getMonth() && date1.getDate() == date2.getDate())
				result=true;

			return result;
		}

		public static function isSameInstant(date1:Date, date2:Date):Boolean {
			Assert.notNull(date1, NOT_NULL_ASSERTION_MESSAGE);
			Assert.notNull(date2, NOT_NULL_ASSERTION_MESSAGE);

			var result:Boolean=false;
			if (date1.getTime() == date2.getTime())
				result=true;

			return result;
		}


		/*
		 *  Add Functions
		 */
		public static function addYears(date:Date, years:Number):Date {
			return addMonths(date, years * MONTHS_PER_YEAR);
		}

		public static function addMonths(date:Date, months:Number):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);

			var result:Date=new Date(date.getTime());
			result.setMonth(date.month + months);
			result=handleShorterMonth(date, result);
			return result;
		}

		public static function addWeeks(date:Date, weeks:int):Date {
			return addDays(date, weeks * DAYS_PER_WEEK);
		}

		public static function addDays(date:Date, days:int):Date {
			var result:Date=add(date, MILLIS_PER_DAY, days);
			return handleDaylightSavingsTime(date, result);
		}

		public static function addHours(date:Date, hours:int):Date {
			return add(date, MILLIS_PER_HOUR, hours);
		}

		public static function addMinutes(date:Date, minutes:int):Date {
			return add(date, MILLIS_PER_MINUTE, minutes);
		}

		public static function addSeconds(date:Date, seconds:int):Date {
			return add(date, MILLIS_PER_SECOND, seconds);
		}

		public static function addMilliseconds(date:Date, milliseconds:int):Date {
			return add(date, 1, milliseconds);
		}

		private static function add(date:Date, multiplier:int, num:int):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			var resultTime:Number=date.getTime() + multiplier * num;
			return new Date(resultTime);
		}

		/*
		 * Set Functions
		 */
		public static function setYear(date:Date, year:int):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			var result:Date=new Date(year, date.month, date.date, date.hours, date.minutes, date.seconds, date.milliseconds);
			return handleShorterMonth(date, result);
		}

		public static function setMonth(date:Date, month:int):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			var result:Date=new Date(date.fullYear, month, date.date, date.hours, date.minutes, date.seconds, date.milliseconds);
			return handleShorterMonth(date, result);
		}

		public static function setDay(date:Date, day:int):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return new Date(date.fullYear, date.month, day, date.hours, date.minutes, date.seconds, date.milliseconds);
		}

		public static function setHours(date:Date, hour:int):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return new Date(date.fullYear, date.month, date.date, hour, date.minutes, date.seconds, date.milliseconds);
		}

		public static function setMinutes(date:Date, minute:int):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return new Date(date.fullYear, date.month, date.date, date.hours, minute, date.seconds, date.milliseconds);
		}

		public static function setSeconds(date:Date, second:int):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return new Date(date.fullYear, date.month, date.date, date.hours, date.minutes, second, date.milliseconds);
		}

		public static function setMilliseconds(date:Date, millisecond:int):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return new Date(date.fullYear, date.month, date.date, date.hours, date.minutes, date.seconds, millisecond);
		}


		/*
		 * Conversion Functions
		 */
		public static function getUTCDate(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return getDateForOffset(date, date.getTimezoneOffset());
		}

		public static function getDateForOffset(date:Date, offsetMinutes:int):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			var offsetMilliseconds:Number=offsetMinutes * MILLIS_PER_MINUTE;
			return new Date(date.getTime() + offsetMilliseconds);
		}


		/*
		 * Period Functions
		 */
		public static function getStartOfYear(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return getStartOfDay(new Date(date.fullYear, 0, 1));
		}

		public static function getStartOfMonth(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return getStartOfDay(new Date(date.fullYear, date.month, 1));
		}

		public static function getStartOfWeek(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return getStartOfDay(new Date(date.fullYear, date.month, date.date - date.day));
		}

		public static function getStartOfDay(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return new Date(date.fullYear, date.month, date.date, 0, 0, 0, 0);
		}

		public static function getUTCStartOfDay(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return new Date(Date.UTC(date.fullYearUTC, date.monthUTC, date.dateUTC, 0, 0, 0, 0));
		}


		public static function getEndOfYear(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return getEndOfDay(new Date(date.fullYear, 11, 31));
		}

		public static function getEndOfMonth(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			var lastDateOfMonth:Date=getStartOfMonth(date);
			lastDateOfMonth=addMonths(lastDateOfMonth, 1);
			lastDateOfMonth=addDays(lastDateOfMonth, -1);
			return getEndOfDay(new Date(lastDateOfMonth.fullYear, lastDateOfMonth.month, lastDateOfMonth.date));
		}

		public static function getEndOfWeek(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return getEndOfDay(new Date(date.fullYear, date.month, date.date - date.day + 6));
		}

		public static function getEndOfDay(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return new Date(date.fullYear, date.month, date.date, 23, 59, 59, 999);
		}

		public static function getUTCEndOfDay(date:Date):Date {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return new Date(Date.UTC(date.fullYearUTC, date.monthUTC, date.dateUTC, 23, 59, 59, 999));
		}

		/*
		 * Diff functions
		 */
		public static function getDaysDiff(startDate:Date, endDate:Date):int {
			return getVariableDiff(startDate, endDate, MILLIS_PER_DAY);
		}

		public static function getHoursDiff(startDate:Date, endDate:Date):int {
			return getVariableDiff(startDate, endDate, MILLIS_PER_HOUR);
		}

		public static function getMinutesDiff(startDate:Date, endDate:Date):int {
			return getVariableDiff(startDate, endDate, MILLIS_PER_MINUTE);
		}
		
		private static function getVariableDiff (startDate:Date, endDate:Date, millsPer:int) : int {
			Assert.notNull(startDate, NOT_NULL_ASSERTION_MESSAGE);
			Assert.notNull(endDate, NOT_NULL_ASSERTION_MESSAGE);
			var startMillis:Number = startDate.getTime();
			var endMillis:Number = endDate.getTime();
			var dstOffset:Number = (startDate.getTimezoneOffset() - endDate.getTimezoneOffset()) * MILLIS_PER_MINUTE;
			return Math.ceil((endMillis - startMillis + dstOffset) / millsPer);
		}


		/*
		 * Misc Functions
		 */

		public static function getLocalTimeZoneCode():String {
			var dateString:String=new Date().toString();
			var startIndex:int=dateString.indexOf(GMT_TIMEZONE_STRING);
			var endIndex:int=dateString.indexOf(" ", startIndex);

			return dateString.substring(startIndex, endIndex);
		}

		public static function isLeapYear(date:Date):Boolean {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			return (date.fullYear % 400 == 0) || ((date.fullYear % 4 == 0) && (date.fullYear % 100 != 0));
		}

		public static function isWeekDay(date:Date):Boolean {
			return !(isWeekEnd(date));
		}

		public static function isWeekEnd(date:Date):Boolean {
			Assert.notNull(date, NOT_NULL_ASSERTION_MESSAGE);
			var dayOfWeek:uint=date.day;
			return dayOfWeek == 0 || dayOfWeek == 6;
		}

		public static function getYesterday():Date {
			var result:Date=new Date();
			result.setDate(result.getDate() - 1);
			return result;
		}

		public static function getTomorrow():Date {
			var result:Date=new Date();
			result.setDate(result.getDate() + 1);
			return result;
		}


		/*
		 * Helper methods
		 */
		private static function handleShorterMonth(originalDate:Date, newDate:Date):Date {
			var result:Date=newDate;
			var originalDayOfMonth:Number=originalDate.getDate();
			if (originalDayOfMonth > result.date) {
				result=addDays(newDate, -(newDate.date));
			}
			return result;
		}

		private static function handleDaylightSavingsTime(originalDate:Date, newDate:Date):Date {
			var result:Date=newDate;
            var originalHours:int=originalDate.hours;
			if (originalHours != result.hours)
				result=addHours(result, -(result.hours - originalHours));
			var originalMinutes:int=originalDate.minutes;
			if (originalMinutes != result.minutes)
				result=addMinutes(result, -(result.minutes - originalMinutes));
            var originalOffset:int = originalDate.getTimezoneOffset()
            if (originalOffset != result.getTimezoneOffset())
                result = addMinutes(result, -(result.getTimezoneOffset() - originalOffset));

			return result;
		}

	}
}