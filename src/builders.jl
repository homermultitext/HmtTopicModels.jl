

"EditionBuilders sharing editorial conventions of a basic MID project."
#abstract type MidBasicBuilder <: EditionBuilder end
struct HmtTMBuilder <: MidBasicBuilder
    name
    versionid
 end

function skipelement(builder::HmtTMBuilder, elname)
    elname in ["del", "ref","note","q","cit"]
end


"Collect text of w element"
#=
function collectw(el, bldr::HmtTMBuilder)
     # collect and squeeze:
     children = nodes(el)
     wordparts = []
     for c in children
         childres = editedtext(bldr, c, "")
         push!(wordparts, childres)
     end
     # single token padded by ws:
     singletoken = replace(join(wordparts,""), r"[ ]+" => "")
end
=#

"Compose edited text of a given XML element using a given builder."
function editedelement(builder::HmtTMBuilder, el, accum)
    if ! validelname(builder, el.name)
        str = ezxmlstring(el)
        msg = "Invalid element $(el.name) in $(str)"
        throw(DomainError(msg))
    end

    reply = []
    if el.name == "foreign"
        push!(reply, "«" * el.content * "»")

    elseif el.name == "choice"
        if ! validchoice(el)
            children = elements(el)
            childnames = map(n -> n.name, children)
            badlist = join(childnames, ", ")
            msg = "Invalid children of `choice` element: $(badlist) in  $(ezxmlstring(el))"
            throw(DomainError(msg))
            
        else
            chosen = "USE THE NORMALIZED" #TEIchoice(builder, el)
            push!(reply, chosen)
        end

    elseif el.name == "w"
        push!(reply, "IMPLEMENT THE W") # collectw(el, builder))
       
        # check for word-fragment convention:
        # `w` with `@n` attribute:
        # mark for subsequent peek-ahead
        #if hasattribute(el, "n")
        #    push!(reply, " ++$(singletoken)++ ")
        #else
        #    push!(reply, " $(singletoken) ")
        #end
       
        
        
    elseif skipelement(builder, el.name)
        # do nothing

    else
        children = nodes(el)
        if !(isempty(children))
            for c in children
                childres =  editedtext(builder, c, accum)
                push!(reply, childres)
            end
        end
    end
    strip(join(reply," "))
end



"""Walk parsed XML tree and compose a specific edition.
`builder` is the edition builder to use. `n` is a parsed Node. 
`accum` is the accumulation of any text already seen and collected.
"""
function editedtext(builder::HmtTMBuilder, n::EzXML.Node, accum = "")::AbstractString
	rslts = [accum]
    if n.type == EzXML.ELEMENT_NODE 
        elresults = editedelement(builder, n, accum)
        push!(rslts, elresults)

	elseif 	n.type == EzXML.TEXT_NODE
		tidier = cleanws(n.content )
		if !isempty(tidier)
			push!(rslts, accum * tidier)
		end
                
    elseif n.type == EzXML.COMMENT_NODE
        # do nothing
    else
        throw(DomainError("Unrecognized node type for node $(n.type)"))
	end
    stripped = strip(join(rslts," "))
    replace(stripped, r"[ \t]+" => " ")
end


#=
"Builder for constructing a citable node for a diplomatic text from a citable node in archival XML."
function editednode(builder::MidBasicBuilder, citablenode::CitableNode)
    nd  = root(parsexml(citablenode.text))
    editiontext = editedtext(builder, nd)
    CitableNode(addversion(citablenode.urn, builder.versionid), editiontext)
end
=#