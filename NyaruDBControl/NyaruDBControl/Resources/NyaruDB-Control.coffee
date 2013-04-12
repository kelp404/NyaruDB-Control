###
    NyaruDB Control CoffeeScript Interface
    Kelp http://github.com/kelp404

    Created by Kelp on 2013/04/10.
###

`
/* JavaScript Date Extension v1.0 */
Date.initWithJSON=function(a){var b=a.replace(RegExp('"|\'','g'),'');b=b.replace(/\\?\/Date\((-?\d+)\)\\?\//,'$1');return new Date(parseInt(b))};Date.Format={masks:{defaultValue:"ddd MMM dd yyyy HH:mm:ss",shortDate:"m/d/yy",mediumDate:"MMM d, yyyy",longDate:"MMMM d, yyyy",fullDate:"dddd, MMMM d, yyyy",shortTime:"h:mm TT",mediumTime:"h:mm:ss TT",longTime:"h:mm:ss TT Z",isoDate:"yyyy-MM-dd",isoTime:"HH:mm:ss",isoDateTime:"yyyy-MM-dd'T'HH:mm:ss",isoUtcDateTime:"UTC:yyyy-MM-dd'T'HH:mm:ss'Z'"},i18n:{dayNames:["Sun","Mon","Tue","Wed","Thu","Fri","Sat","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],monthNames:["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","January","February","March","April","May","June","July","August","September","October","November","December"]}};Date.prototype.toFormat=function(g,h){var i=/\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,timezoneClip=/[^-+\dA-Z]/g,pad=function(a,b){a=String(a);b=b||2;while(a.length<b)a="0"+a;return a};function DateFormat(b,c,e){var f=Date.Format;if(arguments.length==1&&Object.prototype.toString.call(b)=="[object String]"&&!/\d/.test(b)){c=b;b=undefined}b=b?new Date(b):new Date;if(isNaN(b))throw SyntaxError("invalid date");c=String(f.masks[c]||c||f.masks["defaultValue"]);if(c.slice(0,4)=="UTC:"){c=c.slice(4);e=true}var _=e?"getUTC":"get",d=b[_+"Date"](),D=b[_+"Day"](),M=b[_+"Month"](),y=b[_+"FullYear"](),H=b[_+"Hours"](),m=b[_+"Minutes"](),s=b[_+"Seconds"](),L=b[_+"Milliseconds"](),o=e?0:b.getTimezoneOffset(),flags={d:d,dd:pad(d),ddd:f.i18n.dayNames[D],dddd:f.i18n.dayNames[D+7],M:M+1,MM:pad(M+1),MMM:f.i18n.monthNames[M],MMMM:f.i18n.monthNames[M+12],yy:String(y).slice(2),yyyy:y,h:H%12||12,hh:pad(H%12||12),H:H,HH:pad(H),m:m,mm:pad(m),s:s,ss:pad(s),l:pad(L,3),L:pad(L>99?Math.round(L/10):L),t:H<12?"a":"p",tt:H<12?"am":"pm",T:H<12?"A":"P",TT:H<12?"AM":"PM",Z:e?"UTC":(String(b).match(i)||[""]).pop().replace(timezoneClip,""),o:(o>0?"-":"+")+pad(Math.floor(Math.abs(o)/60)*100+Math.abs(o)%60,4),S:["th","st","nd","rd"][d%10>3?0:(d%100-d%10!=10)*d%10]};return c.replace(RegExp(/d{1,4}|M{1,4}|yy(?:yy)?|([HhmsTt])\1?|[LloSZ]|"[^"]*"|\'[^\']*'/g),function(a){return a in flags?flags[a]:a.slice(1,a.length-1)})}return DateFormat(this,g,h)};
`


$ = jQuery

format = (obj) ->
    if obj != null
        switch typeof(obj)
            when 'string' then return "<span class='text-success'>#{obj}</span>"
            when 'number', 'boolean' then return "<span class='text-info'>#{obj}</span>"
            when 'object'
                if obj.constructor == Date
                    # date
                    return "<span class='text-warning'>#{obj.toFormat('yyyy-MM-dd HH:mm:ss')}</span>"
                if obj.constructor == Array
                    # array
                    if typeof(obj[0]) == 'object' and obj[0].constructor != Date
                        # dictionary in array
                        keys = Object.keys obj[0]
                        if 'key' in keys then keys = ['key']
                        else keys = []

                        for doc in obj
                            # check all keys
                            doc_keys = Object.keys doc
                            keys.push(key) for key in doc_keys when key not in keys

                        docs = []   # ["<tr><td>....</td></tr>"]
                        for doc in obj
                            doc_keys = Object.keys doc  # keys in the document
                            doc_clean = []
                            for key in keys
                                if key in doc_keys then doc_clean.push(format(doc[key]))    # append data
                                else doc_clean.push '<span class="muted">missing</span>'    # missing
                            docs.push("<tr><td>#{doc_clean.join('</td><td>')}</td></tr>")

                        return """<table class='table table-bordered table-striped table-hover'>
                               <thead><tr><td>#{keys.join('</td><td>')}</td></tr></thead>
                               <tbody>#{docs.join('')}</tbody>
                               </table>"""
                    else
                        # string, number, date in array
                        result = ("<tr><td>#{format(x)}</td></tr>" for x in obj)
                        return "<table class='table table-bordered table-striped table-hover'><tbody>#{result.join('')}</tbody></table>"
                else
                    # dictionary
                    keys = Object.keys obj
                    if keys
                        return format([obj])
                    else
                        return '<span class="label label-inverse">unknown type</span>'
            when 'function' then return '<span class="label label-inverse">function</span>'
            else
                return '<span class="label label-inverse">unknown type</span>'
    else
        return '<span class="text-error">null</span>'


# clear()
window.clear = -> $('body').html ''

# print()
window.print = (obj) -> $('body').append $("<p>#{format(obj)}</p>")
